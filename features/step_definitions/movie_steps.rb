# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  # ensure that that e1 occurs before e2.
  # page.content is the entire content of the page as a string.
  content = page.body.to_s
  
  # get the position of the movie names in the content string
  e1_index = content.index(e1)
  e2_index = content.index(e2)
  
  assert e1_index < e2_index, "Expected to see #{e1} before #{e2} in the movie list"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  checkAction = (uncheck) ? "uncheck" : "check" # either select check or uncheck
  ratings = rating_list.split ', ' # break apart the ratings passed in
  ratings.each do |r| # for each movie passed in call the appropriate 
  steps %Q{
    When I #{checkAction} "ratings[#{r}]"
  }
  end
end

Then /^movies with the following ratings should (definitely|not) be visible: (.*)$/ do |visible, rating_list|
  should_see_movies = (visible == "definitely")
  ratings = rating_list.split(', ')
  
  # subtract 1 to account for the table header row
  rowCount = all("table#movies tr").count - 1
  
  if should_see_movies
    movies = Movie.find(:all, :conditions => [ "rating IN (?)", ratings ])
  else # should not see these movies, so get a list of all movies NOT IN the given movie list; those are the movies that should be displayed
    movies = Movie.find(:all, :conditions => [ "rating NOT IN (?)", ratings ])
  end
  
  assert movies.count == rowCount , "Expected there to be #{movies.count} movies, not #{rowCount}"
end

Then /I should see all of the movies/ do
  # subtract 1 to account for the table header row
  rowCount = all("table#movies tr").count - 1
  
  assert Movie.count == rowCount, "Expected there to be #{Movie.count} movies, not #{rowCount}"
end