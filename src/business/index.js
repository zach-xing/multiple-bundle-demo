/**
 * @format
 */

import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from '../../app.json';

console.log('加载了 business 包...............................................');

AppRegistry.registerComponent(appName, () => App);
