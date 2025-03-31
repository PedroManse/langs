import Control.DeepSeq
import Control.Exception (IOException, catch)
import Data.ByteString (hGetContents, unpack)
import Data.List
import Data.Text.Encoding (decodeUtf8)
import GHC.IO.IOMode (IOMode (ReadMode, WriteMode))
import GHC.IO.StdHandles (openFile)
import System.Environment

import Control.Monad qualified as M
import Data.List qualified as L
import GHC.IO.Handle (hClose)
import System.Directory qualified as D
import System.Environment qualified as E
import System.IO qualified as I

main =
  do
    let args = getArgs

    let toDoPath = ".todo"
    fileExist <- D.doesFileExist toDoPath
    M.unless fileExist $ I.writeFile toDoPath "\n"
    tds<- readFile toDoPath

    args <- args
    delegate args tds

delegate :: [String] -> [Todo] -> IO ()
delegate [] tds = putStrLn $ showTodos tds
delegate ["ls"] tds = putStrLn $ showTodos tds
delegate ["add", td] tds = saveTodos $ addTodo td tds
delegate ["rm", td] tds = saveTodos $ onTodo td tds deleteTodo
delegate ["flip", td] tds = saveTodos $ onTodo td tds flipTodo
delegate x _ = putStrLn $ "Command " ++ head x ++ " Doesn't exist"

saveTodos = writeFile ".todo" . showTodos

showTodos :: [Todo] -> String
showTodos = intercalate "\n" . map show

data Todo = Todo
  { text :: String
  , done :: Bool
  }

addTodo :: String -> [Todo] -> [Todo]
addTodo text list = Todo{text, done = False} : list

onTodo :: String -> [Todo] -> (Todo -> Maybe Todo) -> [Todo]
onTodo find [] _ = error $ "No such TODO with text: " ++ find
onTodo find (Todo{text, done} : xs) exec
  | find == text = case exec $ Todo{text, done = not done} of
      Just a -> a : xs
      Nothing -> xs
  | otherwise = Todo{text, done} : onTodo find xs exec

flipTodo :: Todo -> Maybe Todo
flipTodo Todo{text, done} = Just Todo{text, done = not done}

deleteTodo :: Todo -> Maybe Todo
deleteTodo _ = Nothing

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
