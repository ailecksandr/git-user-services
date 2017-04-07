module Lib
  module Concerns
    module StateMachine
      def state_machine(column, states)
        assign_reader!(column)

        states.each do |key|
          define_method("#{key}!") { instance_variable_set(column, key) }
          define_method("#{key}?") { instance_variable_get(column) == key }
        end
      end

      def multi_state_machine(column, states)
        assign_reader!(column)

        states.each do |key|
          define_method "#{key}!" do |field|
            instance_variable_get("@#{column}")[field] = key
          end

          define_method "#{key}?" do |field|
            instance_variable_get("@#{column}")[field] == key
          end

          define_method "has_#{key}?" do
            instance_variable_get("@#{column}").values.any? { |state| state == key }
          end
        end
      end

      private

      def assign_reader!(column)
        define_method(column) do
          eval("@#{column} ||= #{Hash.new}")
        end
      end
    end
  end
end
