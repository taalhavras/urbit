import * as React from 'react';
import { BrowserRouter as Router, Route, Link, withRouter } from 'react-router-dom';
import styled, { ThemeProvider, createGlobalStyle } from 'styled-components';
import './css/indigo-static.css';
import './css/fonts.css';
import { light } from '@tlon/indigo-react';

import LaunchApp from './apps/launch/app';
import ChatApp from './apps/chat/app';
import DojoApp from './apps/dojo/app';
import StatusBar from './components/StatusBar';
import GroupsApp from './apps/groups/app';
import LinksApp from './apps/links/app';
import PublishApp from './apps/publish/app';

import GlobalStore from './store/global';
import GlobalSubscription from './subscription/global';
import GlobalApi from './api/global';

// const Style = createGlobalStyle`
//   ${cssReset}
//   html {
//     background-color: ${p => p.theme.colors.white};
//   }
//
//   strong {
//     font-weight: 600;
//   }
// `;

const Root = styled.div`
  font-family: ${p => p.theme.fonts.sans};
  line-height: ${p => p.theme.lineHeights.regular};
  max-height: 100vh;
  min-height: 100vh;
`;

const StatusBarWithRouter = withRouter(StatusBar);

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.ship = window.ship;
    this.store = new GlobalStore();
    this.store.setStateHandler(this.setState.bind(this));
    this.state = this.store.state;

    this.appChannel = new window.channel();
    this.api = new GlobalApi(this.ship, this.appChannel, this.store);
  }

  componentDidMount() {
    this.subscription =
      new GlobalSubscription(this.store, this.api, this.appChannel);
    this.subscription.start();
  }

  render() {
    const channel = window.channel;

    const associations = this.state.associations ? this.state.associations : { contacts: {} };
    const selectedGroups = this.state.selectedGroups ? this.state.selectedGroups : [];

    return (
      <ThemeProvider theme={light}>
        <Root>
          <Router>
            <StatusBarWithRouter props={this.props}
            associations={associations}
            invites={this.state.invites}
            api={this.api}
            />
            <div>
              <Route exact path="/" render={ p => (
                <LaunchApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
              <Route path="/~chat" render={ p => (
                <ChatApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
              <Route path="/~dojo" render={ p => (
                <DojoApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
              <Route path="/~groups" render={ p => (
                <GroupsApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
              <Route path="/~link" render={ p => (
                <LinksApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
              <Route path="/~publish" render={ p => (
                <PublishApp
                  ship={this.ship}
                  channel={channel}
                  selectedGroups={selectedGroups}
                  {...p} />
              )} />
            </div>
          </Router>
        </Root>
      </ThemeProvider>
    );
  }
}

