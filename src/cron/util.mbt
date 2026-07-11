///|
pub fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
pub fn contains(arr : Array[Int], val : Int) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == val {
      return true
    }
  }
  false
}

///|
pub fn sort_unique(values : Array[Int]) -> Array[Int] {
  let sorted = values.copy()
  for i = 1; i < sorted.length(); i = i + 1 {
    let current = sorted[i]
    let mut j = i - 1
    while j >= 0 && sorted[j] > current {
      sorted[j + 1] = sorted[j]
      j -= 1
    }
    sorted[j + 1] = current
  }

  let deduped = []
  for value in sorted {
    if deduped.is_empty() || deduped[deduped.length() - 1] != value {
      deduped.push(value)
    }
  }
  deduped
}

///|
pub fn next_at_or_after(values : Array[Int], target : Int) -> Int? {
  for value in values {
    if value >= target {
      return Some(value)
    }
  }
  None
}

///|
pub fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year(year) { 29 } else { 28 }
    _ => 31
  }
}

///|
pub fn day_of_week(year : Int, month : Int, day : Int) -> Int {
  let adjusted_month = if month < 3 { month + 12 } else { month }
  let adjusted_year = if month < 3 { year - 1 } else { year }
  let q = day
  let k = adjusted_year % 100
  let j = adjusted_year / 100
  let h = (q + 13 * (adjusted_month + 1) / 5 + k + k / 4 + j / 4 + 5 * j) % 7
  (h + 6) % 7
}

///|
pub fn format_int_list(values : Array[Int]) -> String {
  if values.is_empty() {
    return "[]"
  }
  let mut result = "["
  for i = 0; i < values.length(); i = i + 1 {
    if i > 0 {
      result += ", "
    }
    result += values[i].to_string()
  }
  result + "]"
}
