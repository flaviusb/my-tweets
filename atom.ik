entry = method("Add entry in place", title, url, updated, id, content,
  ''((entry
          (title "#{`title}")
          link(href: "#{`url}")
          (updated "#{`updated}")
          (id "#{`id}")
          (content(type: "html") "#{`content}")).)
)
; foo = [{title: "A", url: "A", updated: "just now", id: "A", content: "The flergy blergy wergied the clergy."},
;        {title: "B", url: "B", updated: "just now", id: "B", content: "Nothing to see here citizen. Move along."}]
entries = dsyntax("Map entries data to entries",
  [>theentries]
  basecase = nil
  theentries each(anentry, 
    if(basecase == nil,
      basecase = entry(anentry[:date], "http://flaviusb.net/tweets/#{anentry[:url]}", anentry[:datetimeatom], "http://flaviusb.net/tweets/#{anentry[:url]}", anentry[:linkified]),
      basecase last -> entry(anentry[:date], "http://flaviusb.net/tweets/#{anentry[:url]}", anentry[:datetimeatom], "http://flaviusb.net/tweets/#{anentry[:url]}", anentry[:linkified])))
  ''(''(`basecase))
)
guard = dsyntax("guard(a, b, c) = c if a is nil, otherwise b.",
  [>a, b, c]
  basecase = nil
  if(a != nil,
    basecase = b,
    basecase = c)
  ''(''(`basecase))
)

''(
`doctype("xml")
(feed(xmlns: "http://www.w3.org/2005/Atom")
  (title "#{`data[:title]}")
  link(href: "http://flaviusb.net")
  (updated "#{`data[:updated]}")
  (id (`guard(data[:tag],
        "http://flaviusb.net/hashtags/#{`data[:tag]}",
        "http://flaviusb.net/tweets/")))
  (link(href: "#{`data[:self]}", rel: "self", type: "application/atom+xml"))
  (link(href: "#{`data[:first]}", rel: "first"))
  `guard(data[:previous],
    (link(rel: "previous", href: "#{`data[:previous]}")),
    (//("No previous page")))
  `guard(data[:next],
    (link(rel: "next", href: "#{`data[:next]}")),
    (//("No next page")))
  (link(href: "#{`data[:last]}", rel: "last"))
  (author
    name "Justin (:flaviusb) Marsh"
    email "justin.marsh@flaviusb.net"
  )
  (icon "#{`data[:icon]}")
  `entries(data[:entries])
))
