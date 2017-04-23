functor
import
   GUI
   Input
   PlayerManager
   System
define
   TurnbyTurn
   Simulatenous

   Port
   PlayerPort
   NewPlayer
   LoadPlayer
   NewTurn

   StartTurnByTurn
   StartSimultaneous
   SubAction

   SurfaceTurn
   MakeSurfaceTurn
in
%%%%%%%%%%%Create Player %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Port = {GUI.portWindow}
   {Send Port buildWindow}
   fun {NewPlayer Count}
      if Count > Input.nbPlayer then nil
      else
	 {PlayerManager.playerGenerator {List.nth Input.players Count} {List.nth Input.colors Count} Count} | {NewPlayer Count+1}
      end
   end
   fun {MakeSurfaceTurn I}
      if I >= Input.nbPlayer then nil
      else
	 0 | {MakeSurfaceTurn I+1}
      end
   end
   	
   proc {LoadPlayer PlayerPort}
      ID
      Pos
      in
      case PlayerPort of nil then skip
	 [] H|T then
	 {Send H initPosition(ID Pos)}
	 {Send Port initPlayer(ID Pos)}
	 {LoadPlayer T}
      end
   end
%%%%%%%%%%%%%%%%Start Game %%%%%%%%%%%%%%%%%%%%%%%%%%
   PlayerPort = {NewPlayer 1}
   {LoadPlayer PlayerPort}
   SurfaceTurn = {MakeSurfaceTurn 0}

   proc{StartTurnByTurn}
      {System.show 'Entering TurnByTurn'}
      {NewTurn PlayerPort (PlayerPort#SurfaceTurn) true}
   end
  % proc{StartSimultaneous}
      %Launch simultaneous game
  % end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   proc{SubAction Submarine FirstTurn TurnSurface}
      IsSurf
      ID
      Direction
      Position
   in
     {Send Submarine isSurface(ID IsSurf)} %Ask if Submarine is Surface
      if(TurnSurface > 0) then
	 TurnSurface = TurnSurface - 1
	 skip
      elseif(IsSurf orelse FirstTurn) then {Send Submarine dive}
      end
      {Send Submarine move(ID Position Direction)} %Ask for direction
      case Direction of surface then
	  TurnSurface = Input.turnSurface %Add Broadcast and shit
      else
	 {Send Port movePlayer(ID Position)} %Add Broadcast
      end
      
   end

   
   
   proc{NewTurn PlayerPort Data FirstTurn}
      {System.show 'NewTurn'}
      {Delay 1000}
      %Add victory condition to exit loop
      case Data of (nil#nil) then {NewTurn PlayerPort PlayerPort#SurfaceTurn false}
      [] (Submarine|ST)#(IsSurface|IST) then
	 {SubAction Submarine FirstTurn IsSurface}
	 {NewTurn PlayerPort (ST#IST) FirstTurn}
      else
	 skip
      end
   end

   if (Input.isTurnByTurn) then
      {System.show 'TurnByTurn ==>'}
      {System.show PlayerPort#SurfaceTurn}
      {NewTurn PlayerPort (PlayerPort#SurfaceTurn) true}
   end
end