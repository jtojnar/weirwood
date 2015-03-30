module Weirwood.Client (clientMain) where

import Weirwood.API

import Haste.App
import Haste.App.Concurrent
import Haste.DOM
import Haste.Events
import Control.Applicative

-- | Scroll to the bottom of a textarea.
scrollToBottom :: Elem -> Client ()
scrollToBottom el = getProp el "scrollHeight" >>= setProp el "scrollTop"

-- | Client entry point.
clientMain :: API -> Client ()
clientMain api = withElems ["name","message","chat"] $ \[name, message, chat] -> do
  -- Tell the server we're here, and fill out our backlog.
  -- The backlog is stored with newest messags first, so we need to reverse it.
  backlog <- map (\(n, m) -> n ++ ": " ++ m) <$> onServer (apiHello api)

  -- Ask the server for a new message, block until one arrives, repeat
  fork $ let awaitLoop chatlines = do
               setProp chat "value" . unlines . reverse $ take 100 chatlines
               scrollToBottom chat
               (from, msg) <- onServer $ apiAwait api
               awaitLoop $ (from ++ ": " ++ msg) : chatlines
         in awaitLoop backlog

  -- Send a message if the user hits return (charcode 13)
  _ <- message `onEvent` KeyDown $ \k -> do
    case k of
      13 -> do
        m <- getProp message "value"
        n <- getProp name "value"
        setProp message "value" ""
        onServer $ apiSend api <.> (n :: String) <.> (m :: String)
      _ -> do
        return ()
  return ()
