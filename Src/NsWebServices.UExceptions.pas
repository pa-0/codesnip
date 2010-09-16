{
 * NsWebServices.UExceptions.pas
 *
 * Provides exception classes used by web services classes and code.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is NsWebServices.UExceptions.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s)
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit NsWebServices.UExceptions;


interface


uses
  // Delphi
  SysUtils,
  // Indy
  IdHTTP,
  // Project
  UExceptions;


type

  {
  EWebError:
    Base class for exceptions raised by any code that accesses the web.
  }
  EWebError = class(ECodeSnip);

  {
  EHTTPError:
    Exception raised when web server HTTP error is detected.
  }
  EHTTPError = class(EWebError)
  strict private
    fHTTPErrorCode: Integer;  // HTTPErrorCode property value
  public
    constructor Create(const E: EIdHTTPProtocolException); overload;
      {Constructor. Creates object from properties of given exception.
        @param E [in] Instance of exception from which to create this exception.
          E.ReplyErrorCode is stored in HTTPErrorCode property and E.Message is
          stored in Message property.
      }
    procedure Assign(const E: Exception); override;
      {Assigns properties of another exception to this one.
        @param E [in] Exception whose properties are to be copied. Must be an
          EHTTPError or an EIdHTTPProtocolException instance.
      }
    property HTTPErrorCode: Integer read fHTTPErrorCode;
      {HTTP error code from web server}
  end;

  {
  EWebTransmissionError:
    Type of exception raised when an error in transmission over the net is
    detected.
  }
  EWebTransmissionError = class(EWebError);

  {
  EWebConnectionError:
    Exception raised when there is a problem connecting to web server (i.e.
    socket error).
  }
  EWebConnectionError = class(EWebError);

  {
  EWebService:
    Base class for all errors generated by web services. None of these
    exceptions are treated as bugs.
  }
  EWebService = class(EWebError);

  {
  EWebServiceFailure:
    Exception raised when the web service fails to response as expected.
  }
  EWebServiceFailure = class(EWebService);

  {
  EWebServiceError:
    Exception raised when a web service returns an error condition as a response
    to a command. It has a non-zero error code in addition to the error message.
  }
  EWebServiceError = class(EWebService)
  strict private
    fErrorCode: Integer;  // Value of ErrorCode property
  public
    constructor Create(const Msg: string; const ErrorCode: Integer = -1);
      overload;
      {Constructor. Constructs exception object with an error code in addition
      to standard error message.
        @param Message [in] Error message.
        @param ErrorCode [in] Optional non-zero error code (defaults to -1).
      }
    constructor CreateFmt(const Fmt: string; const Args: array of const;
      const ErrorCode: Integer = -1); overload;
      {Constructor. Constructs exception object with an error code in addition
      to message built from format string and arguments.
        @param Fmt [in] Format for message string.
        @param Args [in] Arguments to be included in formatted message string.
        @param ErrorCode [in] Optional non-zero error code (defaults to -1).
      }
    procedure Assign(const E: Exception); override;
      {Assigns properties of another exception to this one.
        @param E [in] Exception whose properties are to be copied. Must be an
          EWebServiceError instance.
      }
    property ErrorCode: Integer read fErrorCode;
      {Non-zero error code}
  end;


implementation


{ EHTTPError }

procedure EHTTPError.Assign(const E: Exception);
  {Assigns properties of another exception to this one.
    @param E [in] Exception whose properties are to be copied. Must be an
      EHTTPError or an EIdHTTPProtocolException instance.
  }
begin
  Assert((E is EHTTPError) or (E is EIdHTTPProtocolException),
    ClassName + '.Assign: E must be EHTTPError or EIdHTTPProtocolException');
  inherited;
  if E is EHTTPError then
    fHTTPErrorCode := (E as EHTTPError).fHTTPErrorCode
  else
    fHTTPErrorCode := (E as EIdHTTPProtocolException).ErrorCode;
end;

constructor EHTTPError.Create(const E: EIdHTTPProtocolException);
  {Constructor. Creates object from properties of given exception.
    @param E [in] Instance of exception from which to create this exception.
      E.ReplyErrorCode is stored in HTTPErrorCode property and E.Message is
      stored in Message property.
  }
begin
  inherited Create(E.Message);
  fHTTPErrorCode := E.ErrorCode;
end;

{ EWebServiceError }

procedure EWebServiceError.Assign(const E: Exception);
  {Assigns properties of another exception to this one.
    @param E [in] Exception whose properties are to be copied. Must be an
      EWebServiceError instance.
  }
begin
  Assert(E is EWebServiceError,
    ClassName + '.Assign: E must be EWebServiceError');
  inherited;
  fErrorCode := (E as EWebServiceError).fErrorCode;
end;

constructor EWebServiceError.Create(const Msg: string;
  const ErrorCode: Integer);
  {Constructor. Constructs exception object with an error code in addition
  to standard error message.
    @param Message [in] Error message.
    @param ErrorCode [in] Optional non-zero error code (defaults to -1).
  }
begin
  Assert(ErrorCode <> 0, ClassName + '.Create: zero error code');
  inherited Create(Msg);
  fErrorCode := ErrorCode;
end;

constructor EWebServiceError.CreateFmt(const Fmt: string;
  const Args: array of const; const ErrorCode: Integer);
  {Constructor. Constructs exception object with an error code in addition to
  message built from format string and arguments.
    @param Fmt [in] Format for message string.
    @param Args [in] Arguments to be included in formatted message string.
    @param ErrorCode [in] Optional non-zero error code (defaults to -1).
  }
begin
  Assert(ErrorCode <> 0, ClassName + '.CreateFmt: zero error code');
  Create(Format(Fmt, Args), ErrorCode);
end;

end.

