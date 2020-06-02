import React, { Component } from 'react';
import { cite } from '../../../lib/util';
import { Spinner } from '../../../components/Spinner';

export class Input extends Component {
  constructor(props) {
    super(props);
    this.state = {
      awaiting: false,
      type: 'Sending to Dojo'
    };
    this.keyPress = this.keyPress.bind(this);
    this.inputRef = React.createRef();
  }

  componentDidUpdate() {
      this.inputRef.current.setSelectionRange(this.props.cursor, this.props.cursor);
    }

  keyPress = (e) => {
    if ((e.getModifierState('Control') || event.getModifierState('Meta'))
       && e.key === 'v') {
      return;
    }

    e.preventDefault();

    const allowedKeys = [
      'Enter', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Tab'
    ];

    if ((e.key.length > 1) && (!(allowedKeys.includes(e.key)))) {
      return;
    }

  // submit on enter
  if (e.key === 'Enter') {
    this.setState({ awaiting: true, type: 'Sending to Dojo' });
    this.props.api.soto('ret').then(() => {
      this.setState({ awaiting: false });
    });
  } else if ((e.key === 'Backspace') && (this.props.cursor > 0)) {
    this.props.store.doEdit({ del: this.props.cursor - 1 });
    return this.props.store.setState({ cursor: this.props.cursor - 1 });
  } else if (e.key === 'Backspace') {
    return;
  } else if (e.key.startsWith('Arrow')) {
    if (e.key === 'ArrowLeft') {
      if (this.props.cursor > 0) {
        this.props.store.setState({ cursor: this.props.cursor - 1 });
      }
    } else if (e.key === 'ArrowRight') {
      if (this.props.cursor < this.props.input.length) {
        this.props.store.setState({ cursor: this.props.cursor + 1 });
      }
    }
  }

  // tab completion
  else if (e.key === 'Tab') {
    this.setState({ awaiting: true, type: 'Getting suggestions' });
    this.props.api.soto({ tab: this.props.cursor }).then(() => {
      this.setState({ awaiting: false });
    });
  }

  // capture and transmit most characters
  else {
    this.props.store.doEdit({ ins: { cha: e.key, at: this.props.cursor } });
    this.props.store.setState({ cursor: this.props.cursor + 1 });
  }
}

render() {
  return (
    <div className="flex flex-row flex-grow-1 relative">
      <div className="flex-shrink-0">{cite(this.props.ship)}:dojo
      </div>
      <span id="prompt">
        {this.props.prompt}
      </span>
      <input
        autoCorrect="false"
        autoFocus={true}
        className="mono ml1 flex-auto dib w-100"
        id="dojo"
        cursor={this.props.cursor}
        onClick={e => this.props.store.setState({ cursor: e.target.selectionEnd })}
        onKeyDown={this.keyPress}
        onPaste={(e) => {
          const clipboardData = e.clipboardData || window.clipboardData;
          const paste = Array.from(clipboardData.getData('Text'));
          paste.reduce(async (previous, next) => {
            await previous;
            this.setState({ cursor: this.props.cursor + 1 });
            return this.props.store.doEdit({ ins: { cha: next, at: this.props.cursor } });
          }, Promise.resolve());
          e.preventDefault();
          }}
        ref={this.inputRef}
        defaultValue={this.props.input}
      />
      <Spinner awaiting={this.state.awaiting} text={`${this.state.type}...`} classes="absolute right-0 bottom-0 inter pa ba pa2 b--gray1-d" />
    </div>
    );
  }
}

export default Input;
