base = "/var/www/flaviusb.net/htdocs/tweets/"

GenX baseURI = "http://flaviusb.net/"

swap = {
  "Jan" =>  1,
  "Feb" =>  2,
  "Mar" =>  3,
  "Apr" =>  4,
  "May" =>  5,
  "Jun" =>  6,
  "Jul" =>  7,
  "Aug" =>  8,
  "Sep" =>  9,
  "Oct" => 10,
  "Nov" => 11,
  "Dec" => 12
}

datetimeify  = method("Turn the friendly text format into the braindead html5 time element format", text,
  month = swap[text[4..6]]
  day = text[8..9]
  year = text[11..14]
  hour = text[16..17]
  minute = text[19..20]
  second = text[22..23]
  tzoffset = text[28..32]
  return "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}#{tzoffset}")

linkify = method("Add in links to the tweet text - a nop for present", text,
  text)

date2url = method("Get url slug from date text - the disambiguater is added in the main loop rather than here", text,
  month = swap[text[4..6]]
  ; trim day the stupid way
  day = text[8..9]
  if(text[8..8] == "0",
    day = text[9..9])
  year = text[11..14]
  return "#{year}/#{month}/#{day}/")

tweets = FileSystem readFully("tweets.txt")
split_tweets = tweets split("\n") reverse
collected_tweets = []
collected_tweet = {}
state = :content
split_tweets each(tweep,
  collected_tweet[state] = tweep
  if(state == :date,
    collected_tweet[:datetime] = datetimeify(collected_tweet[:date])
    if(!(collected_tweets empty?),
      prev_url = collected_tweets[-1][:url]
      prev_slug = prev_url split("/") [0...-1] join("/") + "/"
      prev_ord = prev_url split("/") [-1] split(".") [0] toRational
      curr_slug = date2url(collected_tweet[:date])
      if(curr_slug == prev_slug,
        collected_tweet[:url] = curr_slug + (prev_ord + 1) + ".html",
        collected_tweet[:url] = curr_slug + "0.html")
      collected_tweet[:prev_longurl] = collected_tweets[-1][:url]
      collected_tweets[-1][:next_longurl] = collected_tweet[:url],
      collected_tweet[:url] = date2url(collected_tweet[:date]) + "/0.html")
    collected_tweets push!(collected_tweet)
    collected_tweet = {}
    state = :content,
    collected_tweet[:linkified] = linkify(collected_tweet[:content])
    state = :date))

collected_tweets each(tweet,
  GenX build(base: base,
    (tweet => tweet[:url]) => "tweet.ik"))
