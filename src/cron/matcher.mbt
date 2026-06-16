
fn contains(arr : Array[Int], val : Int) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == val {
      return true
    }
  }
  return false
}

pub fn CronExpr::matches(self : CronExpr, minute : Int, hour : Int, day_of_month : Int, month : Int, day_of_week : Int) -> Bool {
  contains(self.minutes, minute) &&
  contains(self.hours, hour) &&
  contains(self.days_of_month, day_of_month) &&
  contains(self.months, month) &&
  contains(self.days_of_week, day_of_week)
}

