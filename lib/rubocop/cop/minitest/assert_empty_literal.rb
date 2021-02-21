# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest
      # This cop enforces the test to use `assert_empty`
      # instead of using `assert_equal([], object)`.
      #
      # @example
      #   # bad
      #   assert_equal([], object)
      #   assert_equal({}, object)
      #
      #   # good
      #   assert_empty(object)
      #
      class AssertEmptyLiteral < Cop
        include ArgumentRangeHelper

        MSG = 'Prefer using `assert_empty(%<arguments>s)` over ' \
              '`assert_equal(%<literal>s, %<arguments>s)`.'

        def_node_matcher :assert_equal_with_empty_literal, <<~PATTERN
          (send nil? :assert_equal ${hash array} $...)
        PATTERN

        def on_send(node)
          assert_equal_with_empty_literal(node) do |literal, matchers|
            return unless literal.values.empty?

            args = matchers.map(&:source).join(', ')

            message = format(MSG, literal: literal.source, arguments: args)
            add_offense(node, message: message)
          end
        end

        def autocorrect(node)
          assert_equal_with_empty_literal(node) do |_literal, matchers|
            object = matchers.first

            lambda do |corrector|
              corrector.replace(node.loc.selector, 'assert_empty')
              corrector.replace(first_and_second_arguments_range(node), object.source)
            end
          end
        end
      end
    end
  end
end
