{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE UndecidableInstances   #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE PolyKinds              #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE TypeInType             #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE KindSignatures         #-}

import Data.Kind (Constraint, Type)

{- 
  Exercise 10.1-i 
  Defunctionalize listToMaybe :: [a] -> Maybe a.
-}

listToMaybe :: [a] -> Maybe a 
listToMaybe []    = Nothing 
listToMaybe (x:_) = Just x

newtype ListToMaybe a = ListToMaybe [a]

class Eval' l t | l -> t where 
  eval :: l -> t 

instance Eval' (ListToMaybe a) (Maybe a) where 
  eval (ListToMaybe [])    = Nothing 
  eval (ListToMaybe (x:_)) = Just x 

{- 
  Exercise 10.2-i 
  Defunctionalize 'listToMaybe' at the type-level
-}

type Exp a = a -> Type 
type family Eval (e :: Exp a) :: a 

data ListToMaybe' :: [a] -> Exp (Maybe a)

type instance Eval (ListToMaybe' '[])      = 'Nothing 
type instance Eval (ListToMaybe' (x ': _)) = 'Just x

{- 
  Exercise 10.2-ii
  Defunctionalize foldr' :: (a -> b -> b) -> b -> [a] -> b 
-}

foldr' :: (a -> b -> b) -> b -> [a] -> b 
foldr' _ z [] = z 
foldr' f z (x:xs) = f x (foldr' f z xs) 

data Foldr :: (a -> b -> Exp b) -> b -> [a] -> Exp b

type instance Eval (Foldr _ z '[]) = z 
type instance Eval (Foldr f z (x ': xs)) = Eval (f x (Eval (Foldr f z xs)))

{--------------------}
{- Chapter Examples -}

newtype Fst a b = Fst (a, b)

instance Eval' (Fst a b) a where 
  eval (Fst (a, b)) = a 

data MapList' dfb a = MapList' (a -> dfb) [a] 

instance Eval' dfb dft => 
    Eval' (MapList' dfb a) [dft] where 
  eval (MapList' f []) = [] 
  eval (MapList' f (x:xs)) = eval (f x) : eval (MapList' f xs)

{-- Type-Level --}

-- snd 
data Snd :: (a, b) -> Exp b 
type instance Eval (Snd '(a, b)) = b

-- fromMaybe
data FromMaybe :: a -> Maybe a -> Exp a 
type instance Eval (FromMaybe _1 ('Just a)) = a 
type instance Eval (FromMaybe a 'Nothing)   = a 

-- map 
data MapList :: (a -> Exp b) -> [a] -> Exp [b]

type instance Eval (MapList f '[]) = '[]
type instance Eval (MapList f (x ': xs)) = Eval (f x) ': Eval (MapList f xs)