require File.join(Rails.root, 'lib/development_mail_interceptor.rb')
require File.join(Rails.root, 'lib/enqueued_mail_interceptor.rb')
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env == 'development'
ActionMailer::Base.register_interceptor(EnqueuedMailInterceptor)