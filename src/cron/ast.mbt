pub enum AstNode {
  All(Int, Int) // min, max
  Value(Int)
  Range(Int, Int)
  List(Array[AstNode])
  Step(AstNode, Int)
} derive(Show, Eq)

pub fn AstNode::to_array(self : AstNode, min : Int, max : Int) -> Array[Int] {
  let res = []
  match self {
    All(min, max) => {
      for i = min; i <= max; i = i + 1 {
        res.push(i)
      }
    }
    Value(v) => {
      if v >= min && v <= max {
        res.push(v)
      }
    }
    Range(start, end) => {
      for i = start; i <= end; i = i + 1 {
        if i >= min && i <= max {
          res.push(i)
        }
      }
    }
    List(nodes) => {
      for n in nodes {
        let arr = n.to_array(min, max)
        for val in arr {
           // naive distinct push
           if not(res.contains(val)) {
             res.push(val)
           }
        }
      }
    }
    Step(node, step) => {
       let arr = node.to_array(min, max)
       for i = 0; i < arr.length(); i = i + step {
         res.push(arr[i])
       }
    }
  }
  res
}
