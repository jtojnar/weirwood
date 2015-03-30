-- | A simple chatbox application using Haste.App.
--   While this example could be considerably shorter, the API calls are broken
--   out to demonstrate how one might want to pass them around in a larger
--   program.
import Weirwood.API
import Weirwood.Client
import Weirwood.Server

import Haste.App
import Control.Applicative
import Data.IORef

-- | Launch the application!
main :: IO ()
main = do
  -- Run the Haste.App application. Please note that a computation in the App
  -- monad should never contain any free variables.
  runApp (mkConfig "localhost" 24601) $ do
    -- Create our state-holding elements
    state <- liftServerIO $ do
      clients <- newIORef []
      messages <- newIORef []
      return (clients, messages)

    -- Create an API object holding all available functions
    api <- API <$> remote (hello state)
               <*> remote (send state)
               <*> remote (await state)

    -- Launch the client
    runClient $ clientMain api
