|%
+$  action
  $%  [%serve-dir url-base=path clay-base=path public=?]
      [%unserve-dir url-base=path]
      [%toggle-permission url-base=path]
      [%set-landscape-homepage-prefix prefix=(unit term)]
  ==
::
+$  configuration
  $:  landscape-homepage-prefix=(unit term)
  ==
::
+$  update
  $%  [%configuration =configuration]
  ==
--
