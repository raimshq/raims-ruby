# frozen_string_literal: true

require_relative '../lib/raims'

root = File.expand_path('..', __dir__)
baseline_path = File.join(root, 'contracts/ruby-api.json')
unless ARGV.empty? || ARGV == ['--write']
  abort 'Usage: ruby scripts/check-compatibility.rb [--write]'
end

definition = lambda do |method|
  {
    'owner' => method.owner.name || method.owner.to_s,
    'parameters' => method.parameters.map { |kind, parameter| [kind.to_s, parameter&.to_s] }
  }
end

sdk_owner = lambda do |owner|
  name = owner.name || owner.to_s
  name.start_with?('Raims::', '#<Class:Raims::')
end

signature = lambda do |owner, methods|
  methods.sort.to_h do |name|
    [name.to_s, definition.call(owner.instance_method(name))]
  end
end

gemspec = Dir.chdir(root) { Gem::Specification.load(File.join(root, 'raims.gemspec')) }
abort 'The Ruby gem specification is missing.' unless gemspec
dependencies = gemspec.runtime_dependencies
abort 'Runtime dependency names must be unique.' unless dependencies.map(&:name).uniq.length == dependencies.length
runtime_dependencies = dependencies.sort_by(&:name).to_h do |dependency|
  [dependency.name, dependency.requirement.requirements.map { |operator, version| [operator, version.to_s] }.sort]
end

symbols = {}
inherited_core_instance_methods = []
inherited_core_class_methods = []
Raims.constants(false).sort.each do |name|
  next if %i[VERSION Util Schema].include?(name)
  value = Raims.const_get(name, false)
  next unless value.is_a?(Module)
  instance_methods = value.public_instance_methods
  class_methods = value.singleton_class.public_instance_methods
  owned_instances, core_instances = instance_methods.partition { |member| sdk_owner.call(value.instance_method(member).owner) }
  owned_classes, core_classes = class_methods.partition { |member| sdk_owner.call(value.singleton_class.instance_method(member).owner) }
  inherited_core_instance_methods.concat(core_instances.map(&:to_s))
  inherited_core_class_methods.concat(core_classes.map(&:to_s))
  constructor = if value.is_a?(Class)
                  {
                    'initialize' => definition.call(value.instance_method(:initialize)),
                    'new' => value.respond_to?(:new) ? definition.call(value.method(:new)) : nil
                  }
                end
  symbols[name.to_s] = {
    'ancestors' => value.ancestors.map(&:name).compact.reject { |item| item.start_with?('JSON::') },
    'constructor' => constructor,
    'instance_methods' => signature.call(value, owned_instances),
    'class_methods' => signature.call(value.singleton_class, owned_classes),
    'constants' => value.constants(false).sort.each_with_object({}) do |constant, result|
      child = value.const_get(constant, false)
      result[constant.to_s] = child if [String, Integer, Float, TrueClass, FalseClass, NilClass, Array, Hash].any? { |type| child.is_a?(type) }
    end
  }
end
current = JSON.parse(JSON.generate({
  'format' => 2,
  'inherited_core_instance_methods' => inherited_core_instance_methods.uniq.sort,
  'inherited_core_class_methods' => inherited_core_class_methods.uniq.sort,
  'runtime_dependencies' => runtime_dependencies,
  'symbols' => symbols
}))
symbols = current.fetch('symbols')

if ARGV == ['--write']
  File.write(baseline_path, JSON.pretty_generate(current) + "\n")
  puts "Wrote #{symbols.length} public Ruby definitions. Review the baseline diff."
  exit
end

abort 'The Ruby compatibility baseline is missing.' unless File.file?(baseline_path)
baseline = JSON.parse(File.read(baseline_path))
abort 'The Ruby compatibility baseline format is unsupported.' unless baseline['format'] == 2 && baseline['symbols'].is_a?(Hash) && baseline['runtime_dependencies'].is_a?(Hash)
failures = []
failures << 'runtime_dependencies' unless baseline['runtime_dependencies'] == current['runtime_dependencies']
baseline['symbols'].each do |name, previous|
  actual = symbols[name]
  if actual.nil?
    failures << name
    next
  end
  failures << "#{name}.ancestors" unless actual['ancestors'] == previous['ancestors']
  failures << "#{name}.constructor" unless actual['constructor'] == previous['constructor']
  %w[instance_methods class_methods constants].each do |kind|
    previous.fetch(kind).each do |member, definition|
      failures << "#{name}.#{member}" unless actual.fetch(kind).key?(member) && actual[kind][member] == definition
    end
  end
  %w[instance class].each do |scope|
    introduced = actual.fetch("#{scope}_methods").keys - previous.fetch("#{scope}_methods").keys
    shadowed = baseline.fetch("inherited_core_#{scope}_methods") & introduced
    failures.concat(shadowed.map { |member| "#{name}.#{member} shadows an inherited core API" })
  end
end
abort "Public Ruby API changed: #{failures.join(', ')}" unless failures.empty?
puts "Checked #{baseline['symbols'].length} public Ruby definitions."
