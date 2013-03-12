require File.join(Rails.root, 'lib/development_mail_interceptor.rb')
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) unless APP_CONFIG['send_emails']