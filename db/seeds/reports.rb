module Seeds
  class Reports
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("reports", "journal_reports", "aggregated_data")
        seed_reports
      end

      private

      def seed_reports
        puts "Seeding reports..."
        return if journals.empty?

        reports_data.each do |start_date, end_date|
          report = Report.create!(start_date: start_date, end_date: end_date)
          create_journal_reports(report)
          create_aggregated_data(report)
        end
      end

      def reports_data
        [
          [3.months.ago.to_date, 2.months.ago.to_date],
          [2.months.ago.to_date, 1.month.ago.to_date],
          [1.month.ago.to_date, Time.current.to_date]
        ]
      end

      def create_journal_reports(report)
        journals.sample(rand(2..4)).each do |journal|
          JournalReport.create!(journal: journal, report: report)
        end
      end

      def create_aggregated_data(report)
        aggregated_data_types.each do |type|
          AggregatedDatum.create!(
            report:,
            type:,
            value: rand(10.0..1000.0).round(2),
            additional_text: Faker::Lorem.sentence(word_count: 2)
          )
        end
      end

      def aggregated_data_types
        %w[AggregatedNumericalDatum AggregatedBooleanDatum]
      end

      def journals = Journal.all
    end
  end
end
