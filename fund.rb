# Problem:
# We have many funds open around the world. Each fund is only relevant to a particular catchment area. Applications from locations
# outside the catchment area should not be accepted to the fund.
# When we receive an application for funding, we need to figure out if it can be accepted into any of our funds.
#
# Below is an example of some code that could be used do this, and we'd like you to review it as if it was a PR.
# Please copy this code into your own local editor. Then you can write comments above the line you want to leave
# a suggestion on. There's no need to actually fix the code :) When you're done, you can just send the entire text, or a new gist, directly
# to us.
#
# This is not real production code, and we're sure there are many more issues than the ones we are aware of :D
# We don't expect you to find them all! 

# We'd just like you to give some quick suggestions on how you might improve it,
# questions you might ask your colleague, or if you think it's ready to ship.
#
# Please don't spend any no longer than 10-20 mins reviewing the code - we value your time and don't want to waste it!
#
# The catchment area for a fund is defined by the `location_match` method in the FundAccount class.
# You can treat the `process_application_created_event` method as the entrypoint.











# i think methods should do one thing, they are harder to test and reason when more than one thing are combined
#  Why are we reversing the fund accounts ?
def process_application_created_event(application)
  fund_accounts = FundAccount.all.sort_by(&:criteria_location_matching_priority).reverse
  fund_accounts.each do |fund_account|
    if fund_account.match_location?(application.full_address, application.latlong)
      allocate_funding_to_application(application, fund_account)
      return
    end
  end

  puts "No allocatable fund for this location"
end

# We can use an  array of objects i belive that this will be cleaner and better and give the object the name of type
# and by doing this we can even add more types easily and manipluate it better
# it might be better to declar varaibles to store the integer/string values for center and points, just to make them more readable and searchable
class FundAccount
  def location_match
    Circle type
    {
      'type' => 'circle',
      'options' => {
        'centre' => [53.270668, -9.0567905],
        'radius' => 10000,
      }
    }

    Polygon type
    {
      'type' => 'polygon',
      'options' => {
        'centre' => [53.270668, -9.0567905],
        'points' => [[53.369669, -6.349048], [53.358093, -6.356429], [53.346720, -6.337976]],
      }
    }

    Region type
    {
      'type' => 'region',
      'options' => {
        'centre' => [53.270668, -9.0567905],
        'regions' => ['london', 'brighton'],
      }
    }
  end

  # what is the 2 supposed to do here ?
  # the polygon is missing as well
  # it might be better to use polymorphism to achieve the same task in different cases, methods are better off performing one thing 
  # in this case method does more than one thing, but this works, the idea is just to make it cleaner :)
  def criteria_location_matching_priority
    case location_match['type']
    when 'circle'
      2
    when 'region'
      (location_match.dig('options', 'regions') == ['*']) ? 0 : 1
    else
      raise "Matching priority not defined for type '#{location_match['type']}'"
    end
  end

  # private methods are for internal usage within the defiened class FundAccount, it might be cleaner to put this method after
  # matches_location by the there types
  # it could also be better to use case/when statment becasue it is much cleaner than using if statement
  def match_location?(region: nil, latlong: nil)
    if location_match['type'] == 'region'
      matches_location_by_region?(location_match, region)
    elsif location_match['type'] == 'circle'
      matches_location_by_point?(location_match, latlong)
    elsif location_match['type'] == 'polygon'
      matches_location_by_polygon?(location_match, latlong)
    else
      raise "unexpected location match type: #{location_match}"
    end
  end

  # instead of having repeated code, we can write private 
  # and then all the methods below will be considered as private 
  private def matches_location_by_point?(location_match, latlong)
    return false if latlong.nil?

    center = location_match['options']['centre']
    radius = location_match['options']['radius']


    GeoService.distance_between(center, latlong) <= radius
  end

  private def matches_location_by_region?(location_match, region)
    return false if region.nil?

    return true if location_match['options']['regions'] == ["*"]

    location_regions = [*location_match['options']['regions']].map { |region| Regexp.escape(region) }

    region.match(/\b#{location_regions.join('|')}\b/i)
  end

  private def matches_location_by_polygon?(location_match, latlong)
    return false if latlong.nil?

    GeoService.point_inside_polygon?(latlong, location_match['options']['points'])
  end
end
