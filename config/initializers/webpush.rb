# frozen_string_literal: true

DEFAULT_WEBPUSH_CONTACT = 'support@primero.org'
DEFAULT_WEBPUSH_PAUSE_AFTER_MINUTES = 1440

enable_webpush = ActiveRecord::Type::Boolean.new.cast(ENV.fetch('PRIMERO_WEBPUSH', false)) &&
                 ENV['PRIMERO_WEBPUSH_VAPID_PRIVATE'].present? &&
                 ENV['PRIMERO_WEBPUSH_VAPID_PUBLIC'].present?

Rails.application.configure do
  config.x.webpush.enabled = enable_webpush
  if enable_webpush
    primero_webpush_contact = ENV.fetch('PRIMERO_WEBPUSH_CONTACT', nil)
    config.x.webpush.vapid_private = ENV.fetch('PRIMERO_WEBPUSH_VAPID_PRIVATE', nil)
    config.x.webpush.vapid_public = ENV.fetch('PRIMERO_WEBPUSH_VAPID_PUBLIC', nil)
    config.x.webpush.contact =
      primero_webpush_contact =~ URI::MailTo::EMAIL_REGEXP ? primero_webpush_contact : DEFAULT_WEBPUSH_CONTACT
    config.x.webpush.pause_after =
      ENV['PRIMERO_WEBPUSH_PAUSE_AFTER'].to_i.positive? || DEFAULT_WEBPUSH_PAUSE_AFTER_MINUTES
  end
end
