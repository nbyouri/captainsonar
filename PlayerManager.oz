functor
import
   Player100TargetPractice
   PlayerBasicAI
   Player033RandAI
   Player010DrunkAI
   Player99SeekDestroy
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
      of nil then nil
      []targetPractice then
	 {Player100TargetPractice.portPlayer Color ID}
      []playerBasicAI then
	 {PlayerBasicAI.portPlayer Color ID}
      []player033RandAI then
	 {Player033RandAI.portPlayer Color ID}
      []playerDrunkAI then
	 {Player010DrunkAI.portPlayer Color ID}
      []seekDestroy then
	 {Player99SeekDestroy.portPlayer Color ID}
      else
	 nil
      end
   end
end

	 