module Bold
  module Stats
    class Ahoy

      TIME_FRAMES = {
        month: 4.weeks,
        quarter: 12.weeks,
        year: 1.year
      }

      attr_reader :from, :to

      def initialize(site:, to:, from: (to - 4.weeks))
        @site = site
        @to = to.end_of_day
        @from = from.beginning_of_day
      end

      def from_date; @from.to_date end
      def to_date; @to.to_date end

      def time_frames
        TIME_FRAMES
      end

      def daily_pageviews
        @daily_pageviews ||= DailyPageViews.new(site:@site, from:@from, to:@to).compute
      end

      def daily_visits
        @daily_visits ||= DailyVisits.new(site:@site, from:@from, to:@to).compute
      end

      def daily_pageviews_per_visit
        @pageviews_per_visit ||= PageViewsPerVisit.new(site:@site, from:@from, to:@to).compute
      end

      def popular_pages(limit: 7)
        @popular_pages ||= ::Ahoy::Event
          .joins(:visit)
          .where(name: '$view', visits: { site_id: @site.id })
          .where("time >= ? and time <= ?", @from, @to)
          .limit(limit)
          .group("properties->'url', properties->'title'")
          .order('count DESC')
          .pluck("properties->'url', properties->'title'", "count(*) as count")
      end


      def self.for(time_frame:, site:)
        time_frame = TIME_FRAMES.key?(time_frame) ? time_frame : :month
        time_frame_length = TIME_FRAMES[time_frame]
        end_date = site.time_zone.yesterday
        start_date = time_frame_length.before(end_date) + 1.day
        new site: site, to: end_date, from: start_date
      end

      class Metric
        Result = ImmutableStruct.new(:data, :avg, :prev_avg)

        def initialize(site:, to:, from:)
          @site = site
          @to = to
          @from = from
        end

        def compute
          @data ||= begin
            grouped_data, avg = data
            prev_avg = data(delta: (-1 * length)).last
            Result.new(
              data: grouped_data,
              avg: avg,
              prev_avg: prev_avg
            )
          end
        end

        private

        def avg(array, decimals: 0)
          if array.any?
            factor = 10 ** decimals
            ((array.sum.to_f / array.size) * factor).round / factor.to_f
          else
            0
          end
        end

        def data(delta: 0)
          data = self.grouped_data(delta: delta)
          [data, avg(data.values)]
        end

        def length
          @to - @from
        end
      end

      class DailyPageViews < Metric
        def grouped_data(delta: 0)
          ::Ahoy::Event
            .joins(:visit)
            .where(name: '$view', visits: { site_id: @site.id })
            .where("time >= ? and time <= ?", @from+delta, @to+delta)
            .group_by_day(:time,  time_zone: @site.time_zone).count
        end
      end

      class DailyVisits < Metric
        def grouped_data(delta: 0)
          Visit
            .where(site_id: @site.id)
            .where("started_at >= ? and started_at <= ?", @from+delta, @to+delta)
            .group_by_day(:started_at, time_zone: @site.time_zone).count
        end
      end

      class PageViewsPerVisit < Metric
        def grouped_data(delta: 0)
          data = Visit
            .where(site_id: @site.id)
            .where("started_at >= ? and started_at <= ?", @from+delta, @to+delta)
            .joins('inner join ahoy_events on ahoy_events.visit_id = visits.id')
            .group('visits.id')
            .pluck(:started_at, 'count(ahoy_events.id)')
            .group_by{ |row| row[0].in_time_zone(@site.time_zone).to_date }
          data.values.each{|row| row.map! &:last }
          Hash[data.map {|date, values| [date, avg(values, decimals: 1)] }]
        end
      end


    end
  end
end
