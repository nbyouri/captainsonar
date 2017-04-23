functor
import
   Player100TargetPractice
   System
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
      else
	 nil
      end
   end
end

	 