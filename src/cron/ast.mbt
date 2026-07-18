///|
pub(all) enum AstNode {
  All(Int, Int) // min, max bounds (0, 0) placeholder usually
  Value(Int)
  Range(Int, Int)
  LastDay
  List(Array[AstNode])
  Step(AstNode, Int)
} derive(Debug, Eq)

///|
pub fn AstNode::is_all(self : AstNode) -> Bool {
  match self {
    All(_, _) => true
    _ => false
  }
}

///|
pub fn AstNode::has_last_day(self : AstNode) -> Bool {
  match self {
    LastDay => true
    List(nodes) => {
      let mut has = false
      for n in nodes {
        if n.has_last_day() {
          has = true
        }
      }
      has
    }
    Step(node, _) => node.has_last_day()
    _ => false
  }
}

///|
pub fn AstNode::has_stepped_last_day(self : AstNode) -> Bool {
  match self {
    Step(node, _) => node.has_last_day()
    List(nodes) => {
      let mut has = false
      for n in nodes {
        if n.has_stepped_last_day() {
          has = true
        }
      }
      has
    }
    _ => false
  }
}

///|
pub fn AstNode::to_array(
  self : AstNode,
  min : Int,
  max : Int,
) -> Result[Array[Int], CronError] {
  let res = []
  match self {
    All(_, _) =>
      for i = min; i <= max; i = i + 1 {
        res.push(i)
      }
    Value(v) =>
      if v >= min && v <= max {
        res.push(v)
      } else {
        return Err(OutOfBounds("Value out of bounds"))
      }
    Range(start, end) => {
      if start < min || end > max || start > end {
        return Err(OutOfBounds("Range out of bounds or invalid"))
      }
      for i = start; i <= end; i = i + 1 {
        res.push(i)
      }
    }
    LastDay => ()
    List(nodes) =>
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
