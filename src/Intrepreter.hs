module Intrepreter where 
import Ast

{-
eval :: Expr -> Env -> Int
eval (Lit n) env        = n
eval (Plus x y) env     = let x' = eval x env 
                              y' = eval y env
                              in x' + y'
eval (Mult x y) env     = let x' = eval x env 
                              y' = eval y env
                              in x' * y' 
eval (Minus x y) env     = let x' = eval x env 
                               y' = eval y env
                               in x' - y'
-}


-- add expressions now B

eval :: Expr -> Env -> LVal 
eval (Lit n) e = LFloat n 
eval (Id n) e = case lookup n e of
   (Just x) -> eval x e
   Nothing  -> error "fuck"
eval (Plus xs) e =  primAdd xs  e (LFloat 0) 
eval (Mult xs) e =  primMult xs e (LFloat 1) 
eval (Cond TrueC e1 e2) e =  eval e1 e
eval (Cond FalseC e1 e2) e =  eval e2 e
eval (Minus xs) e = primMinus xs e (LFloat 0) 
eval _       e = error "wtf eval"



-- DO NOT READ PAST THIS POINT
-- IF YOU WANT TO KEEP YOUR SANITY

primMinus :: [Expr] -> Env -> LVal -> LVal
primMinus [] e r           = r 
primMinus ((Lit x):xs) e (LFloat r) = primAdd xs e (LFloat $ r-x)
primMinus ((Str x):xs) e (LFloat r) = error "Minusing strings? What do YOU suggest should happen?" 
primMinus ((w@(Plus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMinus xs e (LFloat (r - g))
primMinus ((w@(Minus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMinus xs e (LFloat (r - g))
primMinus ((w@(Mult x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMinus xs e (LFloat (r - g))
primMinus ((w@(Id x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMinus xs e (LFloat (r - g))


primAdd :: [Expr] -> Env -> LVal -> LVal
primAdd [] e r           = r 
primAdd ((Str x):xs) e (LFloat r) = error "Adding strings? What do YOU suggest should happen?" 
primAdd ((Lit x):xs) e (LFloat r) = primAdd xs  e (LFloat $ r+x)
primAdd ((w@(Plus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primAdd xs e (LFloat (r + g))
primAdd ((w@(Minus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primAdd xs e (LFloat (r + g))
primAdd ((w@(Mult x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primAdd xs e (LFloat (r + g))
primAdd ((w@(Id x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primAdd xs e (LFloat (r + g))

primMult :: [Expr] -> Env -> LVal -> LVal
primMult [] e r           = r 
primMult ((Str x):xs) e (LFloat r) = error "Multiplying strings? What do YOU suggest should happen?" 
primMult ((w@(Plus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMult xs e (LFloat (r * g))
primMult ((w@(Minus x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMult xs e (LFloat (r * g))
primMult ((w@(Mult x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMult xs e (LFloat (r * g))
primMult ((Lit x):xs)  e (LFloat r) = primMult xs e (LFloat $ r * x)
primMult ((w@(Id x):xs)) e (LFloat r) = let (LFloat g) = eval w e in primMult xs e (LFloat (r * g))
