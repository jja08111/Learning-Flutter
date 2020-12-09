# Sleep data chart

- 하루 단위로 수면을 언제 시작해서 끝났는지 보여주는 차트입니다.  
This is chart that show sleep data per day.

- 기상시간과 수면량이 있으면 차트를 그릴 수 있습니다.

- [이곳](https://software-creator.tistory.com/23)에서 bar chart코드를 이용하여 제작했습니다. 

- `barColor`, `tooltipDuration` 그리고 전체 그래프의 크기를 커스텀 할 수 있습니다.  
You can customize the `barColor`, `tooltipDuration` and size of graph.

- 필요시 데이터 생성 [예제 코드](https://github.com/jja08111/Learning-Flutter/blob/main/Sleep-data-chart/sample_read_data.dart)를 보며 데이터를 생상하기 바랍니다. 

# Sample 

![image](/assets/images/sleep_data_chart.gif)

# update 

## 0.0.1
- 업로드 

## 0.1.1 
- 바를 길게 터치(onLongPressed)하면 수면량을 보이는 툴팁기능 추가 
- 하루에 수면량을 표시하는 바를 2개 이상 추가 가능  
날짜가 겹치면 동일한 x축에 표시 

## 0.1.2 
- `cuttingHour`를 이용하여 기준이 되는 시간을 설정할 수 있다.  
  기준이 되는 시간은 어느 시간을 그래프의 최상단으로 할지 정하는 값이다.  
  초기 값은 `17`이다.  
  Add 'cuttingHour' value that determines which time(hour) is the top of the graph.  
  Default value is 17.

## 0.1.3
- `cuttingHour`을 `topHour`로 이름 변경 
- 자동으로 `topHour`을 계산해주도록 변경

## 0.1.4
- 수면량에 `0`을 넣는 경우 빈 데이터를 표시할 수 있도록 기능 추가
- 배열 인덱스 참조 오류 해결
