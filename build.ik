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

swap2 = {
  "Jan" => "01",
  "Feb" => "02",
  "Mar" => "03",
  "Apr" => "04",
  "May" => "05",
  "Jun" => "06",
  "Jul" => "07",
  "Aug" => "08",
  "Sep" => "09",
  "Oct" => "10",
  "Nov" => "11",
  "Dec" => "12"
}

newbase60 = method("Convertg a number to a newbase60 string", num,
  ret = ""
  if(num == 0,
    return "0")
  space = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ_abcdefghijkmnopqrstuvwxyz"
  num = num abs
  mod = num % 60
  div = intify(java:lang:Math floor(num / 60.0))
  ret = space[mod..mod] + ret
  while(div != 0,
    mod = div % 60
    div = intify(java:lang:Math floor(div / 60.0))
    ret = space[mod..mod] + ret)
  ret)

intify = method(num, java:lang:Double new(num) intValue asRational)

isleap = method(y,
  (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)))

ymdptod = method(y,m,d,
  md = [[0,31,59,90,120,151,181,212,243,273,304,334],[0,31,60,91,121,152,182,213,244,274,305,335]]
  return md[if(isleap(y), 1, 0)][m-1]+d)

lyrs = method(y, 
  t1 = intify(java:lang:Math floor(y / 4.0))
  t2 = intify(java:lang:Math floor(y / 100.0))
  t3 = intify(java:lang:Math floor(y / 400.0))
  (t1 - t2) + t3)

rellyrs = method(y, lyrs(y) - lyrs(1970))

datetimeifyb60 = method(text,
  month = swap[text[4..6]]
  day = (text[8..9] toRational) - 1 ; This is because 01 Jan 1970 should be day zero in epoch base 60 days.
  year = text[11..14] toRational
  newbase60(ymdptod(year, month, day) + (((year - 1970) * 365) + rellyrs(year)))
  )
datetimeifyhtml5  = method("Turn the friendly text format into the braindead html5 time element format", text,
  month = swap[text[4..6]]
  day = text[8..9]
  year = text[11..14]
  hour = text[16..17]
  minute = text[19..20]
  second = text[22..23]
  tzoffset = text[28..32]
  return "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}#{tzoffset}")

datetimeifyatom  = method("Turn the friendly text format into the braindead html5 time element format", text,
  month = swap2[text[4..6]]
  day = text[8..9]
  year = text[11..14]
  hour = text[16..17]
  minute = text[19..20]
  second = text[22..23]
  tzoffset = "#{text[28..30]}:#{text[31..32]}"
  return "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}#{tzoffset}")

linkify = method("Add in links to the tweet text - a nop for present", text,
  text)

sanitize = method("Escape <, >, &, ' and \"", text,
  text replaceAll("&", "&amp;") replaceAll("<", "&lt;") replaceAll(">", "&gt;") replaceAll(#["], "&quot;") replaceAll("'", "&apos;"))

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
    collected_tweet[:date] = collected_tweet[:date][0...-1]
    collected_tweet[:datetime] = datetimeifyhtml5(collected_tweet[:date])
    collected_tweet[:datetimeatom] = datetimeifyatom(collected_tweet[:date])
    if(!(collected_tweets empty?),
      prev_url = collected_tweets[-1][:url]
      prev_slug = prev_url split("/") [0...-1] join("/") + "/"
      prev_ord = prev_url split("/") [-1] split(".") [0] toRational
      curr_slug = date2url(collected_tweet[:date])
      if(curr_slug == prev_slug,
        collected_tweet[:url] = curr_slug + (prev_ord + 1) + ".html"
        collected_tweet[:shorturl] = "t/#{datetimeifyb60(collected_tweet[:date])}/#{(prev_ord + 1)}",
        collected_tweet[:url] = curr_slug + "0.html"
        collected_tweet[:shorturl] = "t/#{datetimeifyb60(collected_tweet[:date])}/0")
      collected_tweet[:prev_longurl] = collected_tweets[-1][:url]
      collected_tweets[-1][:next_longurl] = collected_tweet[:url],
      collected_tweet[:url] = date2url(collected_tweet[:date]) + "/0.html"
      collected_tweet[:shorturl] = "t/#{datetimeifyb60(collected_tweet[:date])}/0")
    collected_tweets push!(collected_tweet)
    collected_tweet = {}
    state = :content,
    collected_tweet[:linkified] = linkify(sanitize(collected_tweet[:content]))
    state = :date))

collected_tweets reverse!

; Post the newest tweet here, if invoked as byeloblog.ik build.ik -m
; This should help us to avoid some of the quoting annoyance

post_a_tweet = method("Post a tweet to twitter via coffeescript program.", the_tweet,
  short_tweet = ""
  short_url = "… flaviusb.me/#{the_tweet[:shorturl]}"
  if(the_tweet[:content] length > 140,
    short_tweet = the_tweet[:content][0...(135 - (short_url length))] + short_url,
    short_tweet = the_tweet[:content]) 
  Shell out("coffee", "post.coffee", short_tweet))

if((System programArguments length > 1) && (System programArguments[1] == "-m"),
  tweets_to_tweet = if((System programArguments length > 2), System programArguments[2] toRational, 1)
  collected_tweets[0...(tweets_to_tweet)] reverse each(the_tweet, post_a_tweet(the_tweet)))

individual_rendered_posts = []

tweet_part_template = Message fromText(FileSystem readFully("post.ik"))
tweet_template = Message fromText(FileSystem readFully("tweet.ik"))

collected_tweets each(tweet,
  GenX buildTemplate(base: base,
    (tweet => tweet[:url]) => tweet_template)
  temp_context = XML mimic with(data: tweet)
  individual_rendered_posts unshift!(XML render(tweet_part_template evaluateOn(temp_context, temp_context))))

individual_rendered_posts reverse!

index_data = {
  rendered_posts: individual_rendered_posts join("\n")
}

GenX build(base: "/var/www/flaviusb.net/htdocs/",
  (index_data => "tweets.html") => "index.ik")
  
tweet_counter = 0
tweets_per_page = 50
total_tweets = individual_rendered_posts length
page_num = 0
last_page = total_tweets div(tweets_per_page) + 1
while(tweet_counter < total_tweets,
  atom_data = {
    entries: collected_tweets[tweet_counter...(tweet_counter+tweets_per_page)],
    updated: collected_tweets[0][:datetimeatom],
    self:  "http://flaviusb.net/tweets/atom#{page_num}.atom",
    first: "http://flaviusb.net/tweets/atom0.atom",
    last:  "http://flaviusb.net/tweets/atom#{last_page}.atom",
    title: "flaviusb's 'tweet' feed, page #{page_num + 1}",
    icon:  "http://flaviusb.net/favicon.png"
  }
  if(page_num > 0, atom_data[:previous] = "http://flaviusb.net/tweets/atom#{(page_num - 1)}.atom")
  if((tweet_counter + tweets_per_page) <= total_tweets, atom_data[:next] = "http://flaviusb.net/tweets/atom#{(page_num + 1)}.atom") 
  GenX build(base: "/var/www/flaviusb.net/htdocs/tweets/",
    (atom_data => "atom#{page_num}.atom") => "atom.ik")
  page_num += 1
  tweet_counter += tweets_per_page)
