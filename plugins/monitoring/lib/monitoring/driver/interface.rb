module Monitoring
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base
      
      def alarm_definitions
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_alarm_definition(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_alarm(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def delete_alarm_definition(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def delete_alarm(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def notification_methods
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def alarms(options={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def alarm_states_history(id, options={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def create_notification_method(params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def create_alarm_definition(params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_notification_method(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_notification_method(id,params)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_alarm_definition(id,params)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def list_metrics(params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def list_metric_names()
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
