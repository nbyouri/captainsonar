functor
import
   OS
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   nbPlayer:NbPlayer
   players:Players
   colors:Colors
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   turnSurface:TurnSurface
   maxDamage:MaxDamage
   missile:Missile
   mine:Mine
   sonar:Sonar
   drone:Drone
   minDistanceMine:MinDistanceMine
   maxDistanceMine:MaxDistanceMine
   minDistanceMissile:MinDistanceMissile
   maxDistanceMissile:MaxDistanceMissile
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   NbPlayer
   Players
   Colors
   ThinkMin
   ThinkMax
   TurnSurface
   MaxDamage
   Missile
   Mine
   Sonar
   Drone
   MinDistanceMine
   MaxDistanceMine
   MinDistanceMissile
   MaxDistanceMissile
   GenMap
   GenRow
   AddOnes
   RandomIndex
   MaxOnes
in

%%%% Style of game %%%%
   
   IsTurnByTurn = true

%%%% Description of the map %%%%
   
   NRow = 10
   NColumn = 10

   MaxOnes = 3

   fun{RandomIndex Max}
      ({OS.rand} mod Max)
   end
   
   fun{GenRow NColumn}
      fun{Zero Row}
	 case Row of nil then nil
	 [] _|T then
	    0|{Zero T}
	 end
      end
   in
      {Zero {List.make NColumn}}
   end
   
   fun{GenMap NRow NColumn NOnes}
      fun{GenMapRows Map NColumn}
	 case Map of nil then nil
	 [] _|T then
	    {AddOnes {GenRow NColumn} NRow NOnes}|{GenMapRows T NColumn}
	 end
      end
   in
      {GenMapRows {List.make NRow} NColumn}
   end

   fun{AddOnes Row NRow NOnes}
      fun{One Row Acc I}
	 case Row of nil then nil
	 [] H|T then
	    if I == Acc then
	       if H == 0 then 1|T
	       else 0|T
	       end
	    else
	       H|{One T Acc+1 I}
	    end
	 end
      end
      fun{Ones Row NOnes} NewRow in
	 if NOnes == 0 then
	    NewRow = {One Row 0 {RandomIndex NRow}}
	 else
	    NewRow = {One Row 0 {RandomIndex NRow}}
	    {Ones NewRow NOnes-1}
	 end
      end
   in
      {Ones Row {RandomIndex MaxOnes}}
   end

   Map = {GenMap NRow NColumn MaxOnes}
   %     Map = [[0 0 0 0 0 0 0 0 0 0]
%	     [0 0 0 0 0 0 0 0 0 0]
%	     [0 0 0 1 1 0 0 0 0 0]
%	     [0 0 1 1 0 0 1 0 0 0]
%	     [0 0 0 0 0 0 0 0 0 0]
%	     [0 0 0 0 0 0 0 0 0 0]
%	     [0 0 0 1 0 0 1 1 0 0]
%	     [0 0 1 1 0 0 1 0 0 0]
%	     [0 0 0 0 0 0 0 0 0 0]
%	     [0 0 0 0 0 0 0 0 0 0]]
 %  end

%%%% Players description %%%%
   
   NbPlayer = 4
   Players = [dumb dumb dumb seekDestroy]
   Colors = [green yellow blue red]

%%%% Thinking parameters (only in simultaneous) %%%%
   
   ThinkMin = 500
   ThinkMax = 3000

%%%% Surface time/turns %%%%
   
   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 4

%%%% Number of load for each item %%%%
   
   Missile = 3
   Mine = 3
   Sonar = 3
   Drone = 3

%%%% Distances of placement %%%%
   
   MinDistanceMine = 1
   MaxDistanceMine = 2
   MinDistanceMissile = 1
   MaxDistanceMissile = 4


   
end
