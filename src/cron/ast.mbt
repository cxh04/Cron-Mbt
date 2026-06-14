pub(all) enum AstNode {
  All(Int, Int) // min, max bounds (0, 0) placeholder usually
  Value(Int)
  Range(Int, Int)
  List(Array[AstNode])
  Step(AstNode, Int)
} derive(Show, Eq)

pub fn AstNode::to_array(self : AstNode, min : Int, max : Int) -> Result[Array[Int], CronError] {
  let res = []
  match self {
    All(_, _) => {
      for i = min; i <= max; i = i + 1 {
        res.push(i)
      }
    }
    Value(v) => {
      if v >= min && v <= max {
        res.push(v)
      } else {
        return Err(OutOfBounds("Value out of bounds"))
      }
    }
    Range(start, end) => {
      if start < min || end > max || start > end {
        return Err(OutOfBounds("Range out of bounds or invalid"))
      }
      for i = start; i <= end; i = i + 1 {
        res.push(i)
      }
    }
    List(nodes) => {
      for n in nodes {
        let arr = match n.to_array(min, max) {
          Ok(a) => a
          Err(e) => return Err(e)
        }
        for val in arr {
           if !res.contains(val) {
             res.push(val)
           }
        }
      }
    }
    Step(node, step) => {
       if step <= 0 {
         return Err(InvalidFormat("Step must be positive"))
       }
       let arr = match node.to_array(min, max) {
         Ok(a) => a
         Err(e) => return Err(e)
       }
       for i = 0; i < arr.length(); i = i + step {
         res.push(arr[i])
       }
    }
  }
  Ok(res)
}
