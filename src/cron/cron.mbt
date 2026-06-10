
pub struct CronExpr {
  minutes : Array[Int]
  hours : Array[Int]
  days_of_month : Array[Int]
  months : Array[Int]
  days_of_week : Array[Int]
}

pub enum CronError {
  InvalidFormat(String)
  OutOfBounds(String)
} derive(Show, Eq)

