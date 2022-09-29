# frozen_string_literal: true

require 'puppet/util/feature'

Puppet.features.add(:rgen, libs: ['rgen/metamodel_builder', 'rgen/ecore/ecore'])
