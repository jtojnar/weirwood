module Weirwood.API (Message, State, API(..)) where

import Haste.App
import Data.IORef
import qualified Control.Concurrent as C

-- | A chat message consists of a sender name and a message.
type Message = (String, String)

-- | The type representing our state - a list matching active clients with
--   the MVars used to notify them of a new message, and a backlog of messages.
type State = (IORef [(SessionID, C.MVar Message)], IORef [Message])

-- | Data type to hold all our API calls
data API = API {
    apiHello :: Remote (Server [Message]),
    apiSend  :: Remote (String -> String -> Server ()),
    apiAwait :: Remote (Server Message)
  }
