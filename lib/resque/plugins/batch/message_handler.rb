module Resque
  module Plugins
    class Batch
      # NOTE: This is the default Message handler. It takes lambda to handle each message type.
      # It could be replaced with any other class that responds to send_message(batch, type, msg = {})

      # idle_duration: Set this to a number
      class MessageHandler
        attr_accessor :init_handler,
                      :exit_handler,
                      :idle_handler,
                      :job_handler
                      # :job_start_handler,
                      # :job_stop_handler,
                      # :job_info_handler,
                      # :job_exception_handler

        def initialize(options = {})
          @init_handler = options.fetch(:init, ->(_batch_jobs){})
          @exit_handler = options.fetch(:exit, ->(_batch_jobs){})
          @idle_handler = options.fetch(:idle, ->(_batch_jobs, msg){})

          @job_handler = options.fetch(:job, ->(_batch_jobs, job_id, msg){})

          # @job_start_handler = options.fetch(:job_start, ->(){})
          # @job_stop_handler = options.fetch(:job_stop, ->(){})
          # @job_info_handler = options.fetch(:job_info, ->(){})
          # @job_exception_handler = options.fetch(:job_exception, ->(){})

          @idle_duration = nil
        end

        def send_message(batch, type, msg = {})
          case type
          when :init
            send_init(batch.batch_jobs)
          when :exit
            send_exit(batch.batch_jobs)
          when :idle
            send_idle(batch.batch_jobs, msg)
          when :job
            send_job(batch.batch_jobs, msg)
          else
            raise "unknown message type: #{type}"
          end
        end

        private

        def send_init(batch_jobs)
          init_handler.call(batch_jobs)
        end

        def send_exit(batch_jobs)
          exit_handler.call(batch_jobs)
        end

        def send_idle(batch_jobs, msg)
          idle_handler.call(batch_jobs, msg)
        end

        def send_job(batch_jobs, msg)
          # TODO
          # job_id = msg.delete("job_id")
          job_id = msg["job_id"]
          job_handler.call(batch_jobs, job_id, msg)
        end
      end
    end
  end
end
