functor
import
   GUI
   Input
   PlayerManager
define
   TurnbyTurn
   Simulatenous

   ID
   Pos

   Port
   P1Port
in
   Port = {GUI.portWindow}
   {Send Port buildWindow}
   P1Port = {PlayerManager.playerGenerator Input.players Input.colors Input.nbPlayer}
   {Send P1Port initPosition(ID Pos)}
   {Send Port initPlayer(ID Pos)}
end
