# frozen_string_literal: true

# WebpushNotifier class for RecordActions
class RecordActionWebpushNotifier
  include ApplicationHelper

  def self.transition_notify(transition_notification)
    RecordActionWebpushNotifier.new.transition_notify(transition_notification)
  end

  def self.manager_approval_request(approval_notification)
    RecordActionWebpushNotifier.new.manager_approval_request(approval_notification)
  end

  def self.manager_approval_response(approval_notification)
    RecordActionWebpushNotifier.new.manager_approval_response(approval_notification)
  end

  def transition_notify(transition_notification)
    return if transition_notification.transition.nil?
    return unless webpush_notifications_enabled?(transition_notification&.transitioned_to)

    WebpushService.send_notifications(
      transition_notification&.transitioned_to,
      message_structure(transition_notification.transition)
    )
  end

  def manager_approval_request(approval_notification)
    return unless approval_notification.send_notification?
    return unless webpush_notifications_enabled?(approval_notification.manager)

    WebpushService.send_notifications(
      approval_notification.manager,
      message_structure(approval_notification)
    )
  end

  def manager_approval_response(approval_notification)
    return unless approval_notification.send_notification?
    return unless webpush_notifications_enabled?(approval_notification.owner)

    WebpushService.send_notifications(
      approval_notification.owner,
      message_structure(approval_notification)
    )
  end

  def message_structure(record_action_notification)
    {
      title: I18n.t("webpush_notification.#{record_action_notification.key}.title"),
      body: I18n.t(
        "webpush_notification.#{record_action_notification.key}.body",
        type: record_action_notification&.type
      ),
      action_label: I18n.t('webpush_notification.action_label'),
      link: url_for_v2(record_action_notification.record)
    }
  end

  private

  def webpush_notifications_enabled?(user)
    web_push_enabled? && user_web_push_enabled?(user)
  end

  def user_web_push_enabled?(user)
    return true if user&.receive_webpush?

    Rails.logger.info("Webpush not sent. Webpush notifications disabled for #{user&.user_name || 'nil user'}")

    false
  end

  def web_push_enabled?
    return true if Rails.configuration.x.webpush.enabled

    Rails.logger.info('Webpush notification disabled!!!')

    false
  end

  def root_url
    "#{host_url}/"
  end
end
