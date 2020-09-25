import React from 'react';
import { UIManagerModule } from '@hippy/react';

//import { Device } from '../native';

function ListView3Item(props) {
  return (
    <li nativeName="ListView3Item" {...props} />
  );
}

/**
 * Recyclable list for better performance, and lower memory usage.
 * @noInheritDoc
 */
class ListView3 extends React.Component{


  /**
   * @ignore
   */
  constructor(props) {
    super(props);
    this.handleInitialListReady = this.handleInitialListReady.bind(this);
    this.instance = null;
    this.state = {
      initialListReady: false,
    };
  }

  /**
   * @ignore
   */
  componentDidMount() {
    const { getRowKey } = this.props;
    if (!getRowKey) {
      console.warn('ListView needs getRowKey to specific the key of item');
    }
  }

  /**
   * Scrolls to a given index of itme, either immediately, with a smooth animation.
   *
   * @param {number} xIndex - Scroll to horizon index X.
   * @param {number} yIndex - Scroll To veritical index Y.
   * @param {boolean} animated - With smooth animation.By default is true.
   */
   scrollToIndex(xIndex, yIndex, animated) {
    if (typeof xIndex !== 'number' || typeof yIndex !== 'number' || typeof animated !== 'boolean') {
      return;
    }
    UIManagerModule.callUIFunction(this.instance, 'scrollToIndex', [xIndex, yIndex, animated]);
  }

  /**
   * Scrolls to a given x, y offset, either immediately, with a smooth animation.
   *
   * @param {number} xOffset - Scroll to horizon offset X.
   * @param {number} yOffset - Scroll To veritical offset Y.
   * @param {boolean} animated - With smooth animation.By default is true.
   */
   scrollToContentOffset(xOffset, yOffset, animated) {
    if (typeof xOffset !== 'number' || typeof yOffset !== 'number' || typeof animated !== 'boolean') {
      return;
    }
    UIManagerModule.callUIFunction(this.instance, 'scrollToContentOffset', [xOffset, yOffset, animated]);
  }

   handleInitialListReady() {
    this.setState({ initialListReady: true });
  }

  /**
   * @ignore
   */
   render() {
    let { numberOfRows } = this.props;
    const {
      style,
      renderRow,
      getRowType,
      getRowStyle,
      getRowKey,
      dataSource,
      initialListSize,
      rowShouldSticky,
      onRowLayout,
      ...nativeProps
    } = this.props;
    if (typeof renderRow !== 'function') {
      throw new Error('renderRow props is necessary for ListView');
    }

    const {
      initialListReady,
    } = this.state;
    const itemList = [];

    if (!numberOfRows && dataSource) {
      numberOfRows = dataSource.length;
    }

    if (!initialListReady) {
      numberOfRows = Math.min(numberOfRows, (initialListSize || 10));
    }

    for (let index = 0; index < numberOfRows; index += 1) {
      const itemProps =  {};
      let rowChildren;

      if (dataSource) {
        rowChildren = renderRow(dataSource[index], null, index);
      } else {
        rowChildren = renderRow(index);
      }

      if (typeof getRowKey === 'function') {
        itemProps.key = getRowKey(index);
      }

      if (typeof getRowStyle === 'function') {
        itemProps.style = getRowStyle(index);
      }

      if (typeof onRowLayout === 'function') {
        itemProps.onLayout = (e) => {
          onRowLayout(e, index);
        };
      }

      if (typeof getRowType === 'function') {
        let type = getRowType(index);
        if (type) {
          if (typeof type !== 'string') {
            type = (type).toString();
          }
          itemProps.type = type;
        //   if (Device.platform.OS === 'android') {
        //     itemProps.itemViewType = type;
        //   }
        }
      }

      if (typeof rowShouldSticky === 'function') {
        itemProps.sticky = rowShouldSticky(index);
      }

      if (rowChildren) {
        itemList.push((
          <ListView3Item {...itemProps}>
            {rowChildren}
          </ListView3Item>
        ));
      }
    }

    nativeProps.numberOfRows = itemList.length;
    (nativeProps).initialListSize = initialListSize;
    (nativeProps).style = {
      overflow: 'scroll',
      ...style,
    };

    return (
      <ul
        ref={(ref) => { this.instance = ref; }}
        nativeName="ListView3"
        initialListReady={this.handleInitialListReady}
        {...nativeProps}
      >
        {itemList}
      </ul>
    );
  }
}

/**
* @ignore
*/
ListView3.defaultProps = {
  numberOfRows: 0,
};

export default ListView3;
