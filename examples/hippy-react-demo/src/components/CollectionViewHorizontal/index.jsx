import React from 'react';
import {
  View,
  StyleSheet,
  Text,
  Dimensions
} from '@hippy/react';
import CollectionView from "./list";
const screenWidth = Dimensions.get('window').width;
const screenHeight = Dimensions.get('window').height;
const STYLE_LOADING = 100;
const MAX_FETCH_TIMES = 100;
const mockDataArray = [
  { style: 1 },
  { style: 2 },
  { style: 5 },
  { style: 1 },
  { style: 2 },
  { style: 1 },
  { style: 1 },
  { style: 2 },
  { style: 1 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
  { style: 5 },
];

const styles = StyleSheet.create({
  listviewContainer: {
    width: screenWidth / 3,
    height: 40,
  },
  normalContainer: {
    width:  screenWidth / 3,
    height: 40
  },
  container2: {
    width:  screenWidth / 3,
    height: 40
  },
  container3: {
    width:  screenWidth / 3,
    height: 40
  },
  itemContainer: {
    padding: 24,
  },
  separatorLine: {
    marginLeft: 12,
    marginRight: 12,
    height: 0.5,
    backgroundColor: '#e5e5e5',
  },
  loading: {
    fontSize: 11,
    color: '#aaaaaa',
    alignSelf: 'center',
  },
});


function Style1({ index }) {
  return (
    <View style={styles.container2}>
      <Text numberOfLines={1}>{`${index}: Style 1 222UI`}</Text>
    </View>
  );
}

function Style2({ index }) {
  return (
    <View style={styles.container3}>
      <Text numberOfLines={1}>{`${index}: Style 2 UI`}</Text>
    </View>
  );
}

function Style5({ index }) {
  return (
    <View style={styles.container3}>
      <Text numberOfLines={1}>{`${index}: Style 5 UI`}</Text>
    </View>
  );
}

export default class CollectionViewHorizontal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dataSource: mockDataArray,
      fetchingDataFlag: false,
    };
    this.fetchTimes = 0;
    this.mockFetchData = this.mockFetchData.bind(this);
    this.getRenderRow = this.getRenderRow.bind(this);
    this.onEndReached = this.onEndReached.bind(this);
    this.getRowType = this.getRowType.bind(this);
    this.getRowKey = this.getRowKey.bind(this);
  }

  async onEndReached() {
    const { dataSource, fetchingDataFlag } = this.state;
    // ensure that only one fetching task would be running
    if (fetchingDataFlag) return;
    this.setState({
      fetchingDataFlag: true,
      dataSource: dataSource.concat([{ style: STYLE_LOADING }]),
    });
    const newData = await this.mockFetchData();
    const lastLineItem = dataSource[dataSource.length - 1];
    if (lastLineItem && lastLineItem.style === STYLE_LOADING) {
      dataSource.pop();
    }
    const newDataSource = dataSource.concat(newData);
    this.setState({ dataSource: newDataSource });
  }

  getRowType(index) {
    const self = this;
    const item = self.state.dataSource[index];
    return item.style;
  }

  /* eslint-disable-next-line class-methods-use-this */
  getRowKey(index) {
    return `row-${index}`;
  }

  getRenderRow(index) {
    console.warn("===getRenderRow===", index)
    const { dataSource } = this.state;
    let styleUI = null;
    const rowData = dataSource[index];
    const isLastItem = dataSource.length === index + 1;
    switch (rowData.style) {
      case 1:
        styleUI = <Style1 index={index} />;
        break;
      case 2:
        styleUI = <Style2 index={index} />;
        break;
      case 5:
        styleUI = <Style5 index={index} />;
        break;
      case STYLE_LOADING:
        styleUI = <Text style={styles.loading}>Loading now...</Text>;
        break;
      default:
      // pass
    }
    return (
      <View style={styles.normalContainer}>
        <View style={styles.itemContainer}>
          {styleUI}
        </View>
        {!isLastItem ? <View style={styles.separatorLine} /> : null}
      </View>
    );
  }

  mockFetchData() {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.setState({
          fetchingDataFlag: false,
        });
        this.fetchTimes += 1;
        if (this.fetchTimes >= MAX_FETCH_TIMES) {
          return resolve([]);
        }
        return resolve(mockDataArray);
      }, 1000);
    });
  }

  render() {

    const { dataSource } = this.state;

    return (
      <CollectionView
        style={{ flexDirection: 'row', backgroundColor: '#ffffff' }}
        numberOfSection={dataSource.length}
        initialContentOffset={0}
        scrollEnabled={true}
        renderRow={this.getRenderRow}
        onEndReached={this.onEndReached}
        getRowType={this.getRowType}
        getRowKey={this.getRowKey}
        initialListSize={15}
      />
    );
  }
}
