module Forsa
  class DroppedCart
    attr_reader :logger

    def initialize(logger = STDERR)
      @logger = logger
    end

    def subscribe_dropped_applications
      logger.info "Beginning Forsa::DroppedCart#subscribe_dropped_applications "\
                  "for #{dropped_applications.count} dropped applications"

      dropped_applications.each do |application|
        logger.info "Processing dropped application #{application.id}"

        # if the user closed their tab, dropping an application,
        # but later completed a fresh one for the same email, don't
        # pester them, as they assume they haven't signed up and dutifully
        # complete a second application to make sure
        attempt_subscription(application) unless completed_application_exists?(application.email)
        application.touch(:dropped_cart_processed_at)
      end

      logger.info "Finished Forsa::DroppedCart#subscribe_dropped_applications"
    end

    private

    def dropped_applications
      @dropped_applications ||= MembershipApplication.dropped_cart
    end

    def completed_application_exists?(email)
      MembershipApplication.signed.where(email: email).exists?
    end

    def attempt_subscription(application)
      DroppedCartMailingListSubscriber.new(application).subscribe! if application.dropped_cart_processed_at.nil?
      application.update(dropped_cart_mailchimp_status: '200')
    rescue Gibbon::MailChimpError => e
      logger.error(e)
      application.update(dropped_cart_mailchimp_status: e.status_code)
    end
  end
end
