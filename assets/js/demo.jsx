import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_demo(root, channel) {
  ReactDOM.render(<Layout channel={channel}/>, root);
}

class Layout extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
      cards: [],
      matches: 0,
      clicks: 0,
      flipped: 0,
      current: null,
      prev: null,
      ready: true,
    };
    this.channel.join()
    .receive("ok", this.gotView.bind(this))
    .receive("error", resp => { console.log("Unable to join", resp) });
  }

  gotView(view) {
    this.setState(view.game);
  }

  clicked(card) {
    this.channel.push("clicked", { card: card })
    .receive("ok", this.gotView.bind(this))
    .receive("flip", this.flipBack.bind(this));
  }

  flipBack(view) {
    let match1 = this.state.matches;
    this.gotView(view)
    let match2 = this.state.matches;
    if (match2 > match1) {
      this.channel.push("flip").receive("ok", this.gotView.bind(this))
    }
    else {
      setTimeout(() => {this.channel.push("flip").receive("ok", this.gotView.bind(this))}, 500);
    }
  }

  reset() {
    this.channel.push("reset")
    .receive("ok", this.gotView.bind(this))
  }

  render() {
    let cards = _.map(this.state.cards, (card, ii) => {
      return <RenderCards card={card} clicked={this.clicked.bind(this)} key={ii}/>;
    });
    return (
      <div>
        <div className="row">
          {cards}
        </div>
        <div className="row">
          <div className="col-6">
            <p>Number Of Clicks: {this.state.clicks}</p>
          </div>
        </div>
        <div className="row">
          <div className="col-6">
            <Reset reset={this.reset.bind(this)} />
          </div>
        </div>
      </div>
    )
  }
}

function RenderCards(props) {
  let card = props.card;
  let text = "?";
  if (card.flipped) {
    text = card.letter;
  }
  if (card.matched) {
    text = "DONE"
  }
  return (
    <div className="col-3">
      <div className="letter" onClick={() => props.clicked(card)}>
        {text}
      </div>
    </div>
  )
}

function Reset(props) {
  return <Button className="button1" onClick={() => props.reset()}>RESET</Button>
}
