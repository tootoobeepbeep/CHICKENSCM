{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}


module Parser where
import Text.Megaparsec hiding (State, parse)
import Text.Megaparsec.Char
import qualified  Text.Megaparsec.Char.Lexer as L
import Data.Void
import Data.Text (Text)
import Ast
import Intrepreter
import Data.Maybe
import Control.Applicative hiding (many, some)
import Control.Monad

type Parser = Parsec Void String 

sc :: Parser () 
sc = L.space space1 (L.skipLineComment "//") empty

lexeme = L.lexeme sc 

testStr = "(+ 3 3)" 

op :: Parser Char 
op = choice [char '+', char '-', char '*']


data Sexp 
       = Sym String
       | SNum Float 
       | SList [Sexp]
 deriving Show

pSymbolNoL :: Parser Sexp
pSymbolNoL = Sym <$> 
  ((:) <$> letterChar <*> many alphaNumChar <?> "variable")


pOpNoL :: Parser Sexp
pOpNoL = choice [Sym . (:[]) <$> (char '+')
               , Sym . (:[]) <$> (char '-')
               , Sym . (:[]) <$> (char '*')
                ]

pNumNoL :: Parser Sexp
pNumNoL = SNum <$> L.decimal

pItem :: Parser Sexp
pItem = lexeme pSymbolNoL <|> 
        lexeme pOpNoL     <|>
        lexeme pNumNoL

pItemNoLex :: Parser Sexp
pItemNoLex = pSymbolNoL  <|> 
             pOpNoL      <|>
             pStrPrim    <|>
             pNumNoL     <|>
             pSymbolList 


pItemList :: Parser Sexp
pItemList = SList <$> pItemNoLex `sepBy` char ' ' 

pParens = between (char '(') (char ')') 

pGeeseEyes = between (char '"') (char '"') 


pSymbolList :: Parser Sexp
pSymbolList = pParens pItemList

pStrPrim :: Parser Sexp
pStrPrim = Sym <$> pGeeseEyes (many letterChar)

pSexp :: Parser Sexp
pSexp = pNumNoL <|>
        pStrPrim <|>
        pSymbolList 

-- After the break:
-- finish rewriting parse 
-- then IDK probably finish up
-- do the assIgnment

-- (if test-exp then-exp else-exp) 
-- equality for numbers as boolean
-- implement negation, disjunction, conjunction
-- desugar functions with unary minus
-- + nested if's

parseExprBody :: [Sexp] -> [Expr]
parseExprBody = foldr ((:) . parse) [] 

parseIfCond :: [Sexp] -> Expr
parseIfCond [i, x, xs]  = case i of 
   (Sym "true")  -> Cond TrueC  (parse x) (parse xs)
   (Sym "false") -> Cond FalseC (parse x) (parse xs)
parseIfCond _ = error "bad if statement"

parse :: Sexp -> Expr 
parse (SNum x)     = Lit x
parse (Sym s)   = Id s
parse (SList (x:xs))  = case x of
  (Sym "+") -> Plus $ parseExprBody xs 
  (Sym "-") -> Minus $ parseExprBody xs
  (Sym "*") -> Mult $ parseExprBody xs
  (Sym  "let")  -> Abs $ parseExprBody xs
  (Sym "if") -> parseIfCond xs

testRunParser :: String -> Expr
testRunParser inp = case parseMaybe pSexp inp of
  (Just x) -> parse x
  Nothing  -> parse (Sym "damn")

testRunEval :: String -> LVal 
testRunEval xs = let b = testRunParser xs in eval b  [("h", Lit 3)] 

{-
p :: Parser Expr
p = do 
  char '('
  char '+' 
  space
  x <- lexeme L.decimal
  y <- lexeme L.decimal 
  char ')'
  return (Plus (Lit x) (Lit y))

test :: IO ()
test = do
  x <- getLine 
  let y = parseMaybe p x
  putStrLn $ show $ (eval (fromMaybe (Lit 3) y) [("hi", (Lit 3))])
  test
-}
