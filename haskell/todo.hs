import Data.List
import System.Environment

main =
  let
    args = getArgs
   in
    do
      putStrLn "Hello"

data Todo = Todo
  { text :: String
  , done :: Bool
  }

emap :: (a -> Maybe b) -> (Maybe a -> Maybe b)
emap f (Just a) = f a
emap _ Nothing = Nothing

onTodo' :: String -> [Todo] -> (Maybe Todo -> Maybe Todo) -> [Todo]
onTodo' find [] exec = case exec Nothing of
  Just a -> [a]
  Nothing -> error ""
onTodo' find (Todo{text, done} : xs) exec
  | find == text = case exec $ Just (Todo{text, done = not done}) of
      Just a -> a : xs
      Nothing -> xs
  | otherwise = Todo{text, done} : onTodo' find xs exec

flipTodo :: Todo -> Maybe Todo
flipTodo Todo{text, done} = Just Todo{text, done = not done}

deleteTodo :: Todo -> Maybe Todo
deleteTodo _ = Nothing

addTodo :: String -> Maybe Todo -> Maybe Todo
addTodo tx Nothing = Just Todo{text = tx, done = False}
addTodo _ x = x

doneBox :: Bool -> [Char]
doneBox False = "[ ]"
doneBox True = "[x]"

checkDoneBox :: [Char] -> Bool
checkDoneBox "[ ]" = False
checkDoneBox "[x]" = False
checkDoneBox other = error $ "Can't parse checkbox `" ++ other ++ "`"

instance Show Todo where
  show Todo{text, done} =
    doneBox done ++ ": " ++ text

instance Read Todo where
  readsPrec _ input =
    let
      (done_text, text_fmt) = splitAt 3 input
      done = checkDoneBox done_text -- parse [x] / [ ]
      text = tail $ tail text_fmt -- remove ": "
     in
      [(Todo{text, done}, "")]
