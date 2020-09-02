module Api
  module V1x2
    module Catalog
      class EvaluateOrderProcess
        def initialize(order)
          @order = order
        end

        def process
          # TODO: Update this for when multiple applicable order items
          # can be ordered.
          applicable_order_item = @order.order_items.first

          relevant_order_processes = find_relevant_order_processes

          # TODO: Put the order processes in order by their sequence number before
          # doing this logic
          before_sequence_number = 1
          after_sequence_number = determine_starting_after_sequence_number(relevant_order_processes)

          relevant_order_processes.each do |order_process|
            Catalog::AddToOrderViaOrderProcess.new(before_params(order_process, before_sequence_number)).process
            Catalog::AddToOrderViaOrderProcess.new(after_params(order_process, after_sequence_number)).process

            before_sequence_number += 1
            after_sequence_number -= 1
          end

          applicable_sequence = (relevant_order_processes.length + 1)
          applicable_order_item.update(:process_sequence => applicable_sequence, :process_scope => "applicable")

          self
        end

        private

        def find_relevant_order_processes
          tag_link_query = TagLink.where(:tag_name => all_tags)

          OrderProcess.where(:id => tag_link_query.select(:order_process_id).distinct)
        end

        def all_tags
          portfolio_item_tags = @order.order_items.first.portfolio_item.tags
          portfolio_tags = @order.order_items.first.portfolio_item.portfolio.tags

          (portfolio_item_tags + portfolio_tags).uniq.collect(&:to_tag_string)
        end

        def before_params(order_process, before_sequence_number)
          {
            :order_id          => @order.id,
            :portfolio_item_id => order_process.before_portfolio_item.id,
            :process_sequence  => before_sequence_number,
            :process_scope     => "before"
          }
        end

        def after_params(order_process, after_sequence_number)
          {
            :order_id          => @order.id,
            :portfolio_item_id => order_process.after_portfolio_item.id,
            :process_sequence  => after_sequence_number,
            :process_scope     => "after"
          }
        end

        def determine_starting_after_sequence_number(relevant_order_processes)
          (relevant_order_processes.length * 2) + 1
        end
      end
    end
  end
end
