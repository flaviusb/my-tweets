base = "http://flaviusb.net/"
style = dsyntax("Add style sheet link in place.",
  [location]
  ''(''link(rel: "stylesheet", type: "text/css", href: `location))
)
''(
`doctype("xml")
`doctype("xhtml")
html(xmlns: "http://www.w3.org/1999/xhtml", lang: "en") (head
  (title "Tweet on #{`data[:date]}")
  meta(charset: "utf-8")
  `style("#{`base}reset.css")
  `style("#{`base}style.css")
  `style("#{`base}syntax.css")
  `style("#{`base}mono.css")
  link(rel: "shortcut icon", href: "#{`base}favicon.png", type: "image/png"))
  (body 
    (ul(class: "posts") li (span a(href: "http://flaviusb.net/tweets/#{`data[:url]}", title: "#{`data[:date]}") time(pubdate: "true", datetime: "#{`data[:datetime]}") "#{`data[:datetime]}»") div "#{`data[:linkified]}")
    (div(class: "sidebox")
      (`(if(data[:prev_longurl] == nil || data[:prev_longurl] empty?,
           '(span(class: "grey")  abbr(title: "Previous") "←"),
           ''(a(href: "http://flaviusb.net/tweets/#{`data[:prev_longurl]}")  abbr(title: "Previous") "←"))))
      (`(if(data[:next_longurl] == nil || data[:next_longurl] empty?,
           '(span(class: "grey")  abbr(title: "Next") "→"),
           ''(a(href: "http://flaviusb.net/tweets/#{`data[:next_longurl]}")  abbr(title: "Next") "→"))))
      (form(action: "") (label (span "permalink:") input(size: "26", class: "url permalink", readonly: "readonly", value: "http://flaviusb.net/tweets/#{`data[:url]}", type: "url"))
      //(label (span "shortlink:") input(size: "26", class: "url permalink", readonly: "readonly", value: "http://flaviusb.me/#{`data[:shorturl]}", type: "url"))))
    (p
      a(href: "http://flaviusb.net") "Home"
      " &#160; | &#160; "
      a(rel: "index", href: "http://flaviusb.net/tweets/") "Tweets"
      " &#160; | &#160; "
      a(href: "http://github.com/flaviusb") "Code")))
