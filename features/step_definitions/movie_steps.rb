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
  content = page.body.to_s #Take the entire body of the page and turn it into a string
  
  # get the position of the movie names substrings in the content string
  e1_index = content.index(e1) 
  e2_index = content.index(e2)
  assert e1_index < e2_index, "Expected to see #{e1} before #{e2} in the movie list"
end

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  checkAction = (uncheck) ? "uncheck" : "check" # either select check or uncheck
  ratings = rating_list.split ', ' # break apart the ratings passed in
  ratings.each do |r| # for each movie passed in call the appropriate 
  steps %Q{
    When I #{checkAction} "ratings[#{r}]"
  }
  end
end

Then /^movies with the following ratings should (definitely|not) be visible: (.*)$/ do |visible, rating_list|
  should_see_movies = (visible == "definitely") #Set should_see_movies to visible if they should be visible
  ratings = rating_list.split(', ') #Split the ratings thing into an array to iterate through
  
  # subtract 1 to account for the table header row
  rowCount = all("table#movies tr").count - 1 #count the number of rows by counting occurance
                                              # of table row tag in html
  
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