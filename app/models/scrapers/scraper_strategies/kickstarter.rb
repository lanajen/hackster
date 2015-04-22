module ScraperStrategies
  class Kickstarter < Base

    private
      def before_parse
        @project.one_liner = @parsed.at_css('.NS_project_profiles__blurb').try(:text).try(:strip).try(:truncate, 140)
        super
      end

      def extract_cover_image
        @parsed.at_css('.project-profile__feature_image img') || @parsed.at_css('.project-image img')
      end

      def extract_title
        @parsed.at_css('.NS_project_profile__title h2').try(:text).try(:strip) || @parsed.at_css('.NS_projects__header h2').try(:text).try(:strip)
      end

      def select_article
        # raise @parsed.to_html
        @parsed.at_css('.full-description')
      end

      def title_levels
        1..4
      end
  end
end