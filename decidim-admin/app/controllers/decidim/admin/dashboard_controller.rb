# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < Decidim::Admin::ApplicationController
      helper_method :latest_action_logs, :users_counter

      def show
        enforce_permission_to :read, :admin_dashboard
      end

      private

      def latest_action_logs
        @latest_action_logs ||= Decidim::ActionLog
                                .where(organization: current_organization)
                                .includes(:participatory_space, :user, :resource, :component, :version)
                                .for_admin
                                .order(created_at: :desc)
                                .first(20)
      end

      def users_counter
        last_day = Time.zone.yesterday
        last_week = Time.zone.today.prev_week
        last_month = Time.zone.today.prev_month

        @result = {
          total_admins_last_24: users_count(last_day, true),
          total_admins_last_week: users_count(last_week, true),
          total_admins_last_month: users_count(last_month, true),
          total_participants_last_24: users_count(last_day, false),
          total_participants_last_week: users_count(last_week, false),
          total_participants_last_month: users_count(last_month, false)
        }
      end

      def users_count(date, admin)
        @users_count ||= Decidim::Admin::ActiveUsersCounter.new(
          organization: current_organization,
          date: date,
          admin: admin
        )
      end
    end
  end
end
