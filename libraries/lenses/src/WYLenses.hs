{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

module WYLenses 
  (
    user1
  , user2
  , User(..)
  , UserInfo(..)
  , (.~)
  , (%~)
  ) 
  where 

import Control.Lens hiding ((.~), (%~), (^.))
import qualified Data.Text as T

data User = 
  User {
    _name :: T.Text 
  , _userId :: Int 
  , _metaData :: UserInfo
  } deriving Show 

data UserInfo = 
  UserInfo { 
    _numLogins :: Int 
  , _associatedIPs :: [T.Text] 
  } deriving (Show) 

makeLenses ''User 
makeLenses ''UserInfo

user1 :: User
user1 = User
  { _name = "qiao.yifan"
  , _userId = 103
  , _metaData = UserInfo
    { _numLogins = 20
    , _associatedIPs =
      [ "52.39.193.61"
      , "52.39.193.75"
      ]
    }
  }

user2 :: User 
user2 = User 
  { _name = "nini faroux" 
  , _userId = 104
  , _metaData = UserInfo 
    { _numLogins = 30 
    , _associatedIPs = [] 
    }
  }

infixr 4 .~ 
(.~) :: ((a -> Identity b) -> s -> Identity t) -> b -> s -> t 
(.~) f b s = runIdentity $ f (const $ pure b) s 

infixr 4 %~ 
(%~) :: ((a -> Identity b) -> s -> Identity t) -> (a -> b) -> s -> t 
(%~) f g s = runIdentity $ f (pure . g) s

infixl 8 ^. 
(^.) :: s -> ((a -> Const a b) -> s -> Const a t) -> a 
(^.) s f = getConst $ f Const s

viewName :: User -> T.Text 
viewName u = u ^. name

setName :: User -> T.Text -> User 
setName u nm = u & name .~ nm

viewNumLogins :: User -> Int 
viewNumLogins u = u ^. metaData.numLogins

setNumLogins :: User -> Int -> User 
setNumLogins u n = u & metaData.numLogins .~ n

addIP :: User -> T.Text -> User 
addIP u ip = u & metaData.associatedIPs %~ (ip :)

incrementNumLogins :: User -> User 
incrementNumLogins = metaData.numLogins %~ (+ 1) 

setUserInfo :: User -> UserInfo -> User 
setUserInfo u info = u & metaData .~ info

setUserId :: User -> Int -> User 
setUserId u n = u & userId .~ n

setIPs :: User -> [T.Text] -> User 
setIPs u ips = u & metaData.associatedIPs .~ ips

getIPs :: User -> [T.Text] 
getIPs u = u ^. metaData.associatedIPs

reverseIPs :: User -> User 
reverseIPs u = u & metaData.associatedIPs %~ reverse

capitaliseName :: User -> User 
capitaliseName u = u & name %~ T.toUpper 

allButFirstIP :: User -> User 
allButFirstIP u = u & metaData.associatedIPs %~ take 1

viewIPs :: User -> [T.Text] 
viewIPs u = u ^. metaData.associatedIPs
