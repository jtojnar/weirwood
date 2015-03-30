module Weirwood.Server (hello, send, await) where

import Weirwood.API

import Haste.App
import Control.Monad
import qualified Control.Concurrent as C
import Data.IORef
import qualified Data.Set as S

-- | Tell the server we're here and remove any stale sessions.
hello :: Server State -> Server [Message]
hello state = do
  sid <- getSessionID
  active <- getActiveSessions
  (clients, messages) <- state
  liftIO $ do
    v <- C.newEmptyMVar
    atomicModifyIORef clients $ \cs ->
      ((sid, v) : filter (\(sess, _) -> sess `S.member` active) cs, ())
    readIORef messages

-- | Send a message; keep a backlog of 100 messages.
send :: Server State -> String -> String -> Server ()
send state sender msg = do
  (clients, messages) <- state
  liftIO $ do
    cs <- readIORef clients
    atomicModifyIORef messages $ \msgs -> ((sender, msg):take 99 msgs, ())
    -- Fork a new thread for each MVar so slow clients don't hold up fast ones.
    forM_ cs $ \(_, v) -> C.forkIO $ C.putMVar v (sender, msg)

-- | Block until a new message arrives, then return it.
await :: Server State -> Server Message
await state = do
  sid <- getSessionID
  (clients, _) <- state
  liftIO $ readIORef clients >>= maybe (return ("","")) C.takeMVar . lookup sid

