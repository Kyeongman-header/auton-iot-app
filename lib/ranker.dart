String Ranker(double value, String name){
  //랭커는 데이터들을 받아서 각자의 수치에 따라 total rate을 반환한다.
  //이때 int형 데이터는 double로 강제 형변환 해야한다.
  switch (name){
    case 'khai':
      {
        if (value <= 15) {
          return "쾌적";
        }
        else if (value <= 35) {
           return "주의";
        }
        else if (value <= 75) {
          return "위험";
        }
        else {
          return "매우 위험";
        }
        break;
      }
    case 'temperature':
      {
        if (value < 23)
          {
            return '쾌적';
          }
        else if (value < 40)
          {
            return '주의';
          }
        else if (value < 70)
          {
            return '위험';
          }
        else
          {
            return '매우 위험';
          }
        break;
      }
    case 'humidity':
      {
        if (value <= 60 || value >= 40)
        {
          return '쾌적';
        }
        else if ((value >=20 && value < 40) || (value > 60 && value <=80))
        {
          return '주의';
        }
        else if ((value >=10 && value < 20) || (value > 80 && value <=90))
        {
          return '위험';
        }
        else
        {
          return '매우 위험';
        }
        break;
      }
    case 'CO2':
      {
        if (value < 1000)
        {
          return '쾌적';
        }
        else if (value < 2000)
        {
          return '주의';
        }
        else if (value < 3000)
        {
          return '위험';
        }
        else
        {
          return '매우 위험';
        }
        break;
      }
      case 'P.M 2.5':
    {
      if (value <= 15) {
        return '쾌적';
      }
      else if (value <= 35) {
        return "주의";
      }
      else if (value <= 75) {
        return "위험";
      }
      else {
        return "매우 위험";
      }
      break;
    }
    case 'CO':
      {
        if (value <= 50) {
          return '쾌적';
        }
        else if (value <= 200) {
          return "주의";
        }
        else if (value <= 400) {
          return "위험";
        }
        else {
          return "매우 위험";
        }
        break;
      }
    case 'SO2':
      {
        if (value <= 0.02) {
          return '쾌적';
        }
        else{
          return "주의";
        }

        break;
      }
    case 'NO2':
      {
        if (value <= 0.002) {
          return '쾌적';
        }
        else if (value <= 0.015) {
          return "주의";
        }
        else if (value <= 0.06) {
          return "위험";
        }
        else {
          return "매우 위험";
        }
        break;
      }
    case 'O3':
      {
        if (value <= 0.12) {
          return '쾌적';
        }
        else if (value <= 0.3) {
          return "주의";
        }
        else if (value <= 0.5) {
          return "위험";
        }
        else {
          return "매우 위험";
        }
        break;
      }
    default:
      {
        return '쾌적';
      }
  }
}